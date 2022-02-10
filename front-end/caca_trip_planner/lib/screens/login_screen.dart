import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
// import 'package:wechat_kit/wechat_kit.dart';

import '../screens/main_screen.dart';
import '../screens/singup_screen.dart';
import '../utils.dart';

const url = 'http://152.136.233.65:';

class LoginViaUsernameScreen extends StatefulWidget {
  static const routeName = '/auth/login-via-username';

  const LoginViaUsernameScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<LoginViaUsernameScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  bool _isLoading = false;
  bool _isValidInfo = false;
  bool get _disableButton => _isLoading == true || _isValidInfo == false;
  double rh = 0; // relative height compared to iPhone 13 Pro Max
  double rw = 0; // relative width compared to iPhone 13 Pro Max

  // // 微信登录
  // late final StreamSubscription<BaseResp> _respSubs =
  //     Wechat.instance.respStream().listen(_listenResp);

  // AuthResp? _authResp;

  // void _listenResp(BaseResp resp) {
  //   if (resp is AuthResp) {
  //     _authResp = resp;
  //     final String content = 'auth:${resp.errorCode} ${resp.errorMsg}';
  //     Utils.showMaterialAlertDialog(context, '登录', Text(content));
  //   }
  // }

  @override
  void initState() {
    super.initState();

    nameController.addListener(_checkInfo);
    passwordController.addListener(_checkInfo);
    portController.addListener(_checkInfo);
  }

  @override
  void didChangeDependencies() {
    rh = MediaQuery.of(context).size.height / Utils.h13pm;
    rw = MediaQuery.of(context).size.width / Utils.w13pm;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _respSubs.cancel();
    super.dispose();
  }

  void _checkInfo() {
    setState(() {
      _isValidInfo = portController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  void _login(BuildContext ctx) {
    setState(() {
      _isLoading = true;
    });

    http
        .post(
          Uri.parse(url + portController.text + '/auth/login/registered'),
          body: json.encode({
            'username': nameController.text,
            'password': passwordController.text,
          }),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
        )
        .timeout(const Duration(seconds: 3))
        .catchError((error) {
          Utils.showMaterialAlertDialog(
              ctx, '登录失败', Text(error.toString() + '\n\n请检查端口号!'));
          setState(() {
            _isLoading = false;
          });
        })
        .then(
          (response) {
            setState(() {
              _isLoading = false;
            });
            if (response.statusCode == 200) {
              var body = json.decode(response.body);
              Utils.token = body['token'];
              print(Utils.token);
              Utils.showMaterialAlertDialog(
                  ctx,
                  '登录成功',
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('token: ' + body['token'] + '\n'),
                      Text('username: ' + body['username'])
                    ],
                  )).then((_) => Navigator.of(context).pop());
            } else {
              Utils.showMaterialAlertDialog(
                  ctx,
                  '登录失败',
                  response.body.isEmpty
                      ? Text('未知错误：${response.statusCode}')
                      : const Text('用户名或密码有误！'));
            }
          },
        );
    HapticFeedback.mediumImpact();
  }

  void _goToSingupScreen(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(SignupScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    // The following two lines make sure that the soft keyboard dismisses when user taps elsewhere.
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('密码登录'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              // const SizedBox(
              //   height: 40,
              // ),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 40 * rh, 0, 20 * rh),
                  child: const Text(
                    '卡卡随心游LOGO',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                  )),
              // const SizedBox(height: 40,)
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10 * rw, vertical: 10 * rh),
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  controller: portController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * rw),
                    ),
                    labelText: '端口号',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10 * rw, vertical: 10 * rh),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * rh),
                    ),
                    labelText: '用户名/手机号',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10 * rw, 10 * rh, 10 * rw, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  onEditingComplete: () {
                    _checkInfo();
                    if (_isValidInfo) {
                      _login(context);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: '密码',
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('使用其它方式登录'),
                  ),
                  TextButton(
                    onPressed: () {
                      //forgot password screen
                    },
                    // textColor: Colors.blue,
                    child: const Text('忘记密码'),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              Container(
                width: double.infinity,
                height: 60 * rh,
                padding: EdgeInsets.fromLTRB(10 * rw, 10 * rh, 10 * rw, 0),
                child: ElevatedButton(
                  // textColor: Colors.white,
                  // color: Colors.blue,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 18 * rh,
                          ),
                        ),
                  // The button would be disabled if onPress is null.
                  onPressed: _disableButton ? null : () => _login(context),
                ),
              ),
              Row(
                children: [
                  const Text('还没有卡卡账户？'),
                  SizedBox(
                    width: 60 * rw,
                    child: TextButton(
                      // textColor: Colors.blue,
                      child: const Text(
                        '注册',
                        // style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () => _goToSingupScreen(context),
                    ),
                  ),
                  SizedBox(
                    width: 90 * rw,
                    child: TextButton(
                      // textColor: Colors.blue,
                      child: const Text(
                        '环境检查', // TODO: 替换成微信图标
                        // style: TextStyle(fontSize: 20 * rw),
                      ),
                      onPressed: () async {
                        // final String content =
                        //     'wechat: ${await Wechat.instance.isInstalled()} - ${await Wechat.instance.isSupportApi()}';
                        //   Utils.showMaterialAlertDialog(
                        //       context, '环境检查', Text(content));
                      }, // TODO
                    ),
                  ),
                  SizedBox(
                    width: 90 * rw,
                    child: TextButton(
                      // textColor: Colors.blue,
                      child: const Text(
                        '微信登录', // TODO: 替换成微信图标
                        // style: TextStyle(fontSize: 20 * rw),
                      ),
                      onPressed: () {
                        // Wechat.instance.auth(
                        //   scope: <String>[WechatScope.SNSAPI_USERINFO],
                        //   state: 'auth',
                        // );
                      },
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
