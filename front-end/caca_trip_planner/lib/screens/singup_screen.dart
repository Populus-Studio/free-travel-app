import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/auth/signup';

  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();

  late final rh = MediaQuery.of(context).size.height / Utils.h13pm;
  late final rw = MediaQuery.of(context).size.width / Utils.w13pm;

  bool _isLoading = false;
  bool _isChecked = false;
  bool get _isValidInfo =>
      (_form.currentState?.validate() ?? false) && _isChecked;
  bool get _disableButton =>
      _isValidInfo == false || _isLoading == true || _isChecked == false;
  final _nameDebouncer = Debouncer(milliseconds: 100);
  final _values = {
    // 'port': '',
    'username': '',
    'password': '',
    'phoneNumber': '',
  };

  void _signup(BuildContext ctx) {
    if (_form.currentState!.validate() == false) {
      Utils.showMaterialAlertDialog(
        ctx,
        '登录失败',
        const Text('输入的信息不合法'),
      );
      return;
    }

    _form.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    http
        .post(
      Uri.http(Utils.authority, '/auth/register'),
      body: json.encode({
        'username': _values['username'],
        if (_values['phone']!.isNotEmpty) 'phoneNumber': _values['phone'],
        'password': _values['password'],
      }),
      headers: Utils.jsonHeader,
    )
        // .timeout(const Duration(seconds: 3),
        // onTimeout: () => Utils.showMaterialAlertDialog(
        //     ctx, '注册失败', const Text('请求超时' '\n\n请检查端口号!')))
        .catchError((error) {
      Utils.showMaterialAlertDialog(
          ctx, '注册失败', Text(error.toString() + '\n\n请检查端口号!'));
      setState(() {
        _isLoading = false;
      });
    }).then((response) {
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);
        Utils.showMaterialAlertDialog(
            ctx,
            '注册成功',
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('username: ' + body['data']['username'] + '\n'),
                Text('password: ' + body['data']['password'] + '\n'),
                Text('token: ' + body['data']['token'] + '\n'),
              ],
            )).then((_) {
          Navigator.of(context).pop();
        });
      } else if (response.statusCode == 409) {
        final body = json.decode(response.body);
        // Check if has duplicate phone number.
        if ((body['msg'] as String).contains('phone')) {
          Utils.showMaterialAlertDialog(
            ctx,
            '注册失败',
            const Text('手机号已存在！'),
          );
        } else if ((body['msg'] as String).contains('name')) {
          Utils.showMaterialAlertDialog(
            ctx,
            '注册失败',
            const Text('用户名已存在！'),
          );
        }
      } else {
        Utils.showMaterialAlertDialog(
          ctx,
          '注册失败',
          Text('Error: ' +
              (response.body.isEmpty
                  ? '未知错误：${response.statusCode}'
                  : response.body)),
        );
      }
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('注册'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * rw, vertical: 16 * rh),
          child: Form(
            key: _form,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(0, 40 * rh, 0, 20 * rh),
                    child: const Text(
                      '卡卡随心游LOGO',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                    )),
                // TextFormField(
                //   keyboardType: const TextInputType.numberWithOptions(
                //       signed: false, decimal: false),
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                //   textInputAction: TextInputAction.next,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10 * rh),
                //     ),
                //     labelText: '端口号',
                //   ),
                //   validator: (value) {
                //     if (value?.isEmpty ?? true) {
                //       return '端口号不能为空！';
                //     }
                //     if (!(value?.isValidPort() ?? false)) {
                //       return '端口号应为1-4位数字';
                //     }
                //     return null;
                //   },
                //   onSaved: (value) => _values['port'] = value!,
                // ),
                SizedBox(height: 20 * rh),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * rh),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    _nameDebouncer.run(
                      () => {
                        http
                            .get(Uri.parse(
                                '${Utils.authority}/auth/check/username?username=$value'))
                            .then(
                          (response) {
                            if (response.statusCode == 200) {
                              if (json.decode(response.body)['result'] ==
                                  true) {
                                return '用户名已存在！';
                              }
                            } else {
                              return null;
                            }
                          },
                        )
                      },
                    );
                    return null;
                  },
                  onSaved: (value) => _values['username'] = value!,
                ),
                SizedBox(height: 20 * rh),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * rh),
                    ),
                    labelText: '手机号（可选）',
                    // floatingLabelStyle: !_isLegalPhoneNumber
                    //     ? TextStyle(color: Theme.of(context).errorColor)
                    //     : null,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (!(value?.isValidPhoneNumber() ?? false)) {
                      return '手机号不合法';
                    }
                    return null;
                  },
                  onSaved: (value) => _values['phone'] = value!,
                ),
                SizedBox(height: 20 * rh),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * rh),
                    ),
                    labelText: '密码',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '密码不能为空！';
                    }
                    if (!(value?.isValidPassword() ?? false)) {
                      return '密码至少为8位';
                    }
                    return null;
                  },
                  onSaved: (value) => _values['password'] = value!,
                ),
                SizedBox(height: 10 * rh),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30 * rh,
                      width: 25 * rw,
                      child: Checkbox(
                        onChanged: (val) {
                          setState(() {
                            _isChecked = val ?? false;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: _isChecked,
                        shape: const CircleBorder(),
                      ),
                    ),
                    const Text('我已阅读且同意'),
                    GestureDetector(
                      child: const Text(
                        '《用户协议》',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () => Utils.showMaterialAlertDialog(
                        context,
                        '用户协议',
                        const Text('示例用户协议'),
                      ),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 60,
                  padding: EdgeInsets.fromLTRB(10 * rw, 10 * rh, 10 * rw, 0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * rh),
                      )),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text(
                            '注册',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                    // The button would be disabled if onPress is null.
                    onPressed: _disableButton ? null : () => _signup(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
