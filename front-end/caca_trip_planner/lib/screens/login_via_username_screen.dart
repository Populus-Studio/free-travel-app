import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logintunisia/screens/singup_screen.dart';

const url = 'http://152.136.233.65:';

class LoginViaUsernameScreen extends StatefulWidget {
  static const routeName = '/auth/login/via-username';

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

  @override
  void initState() {
    super.initState();

    nameController.addListener(_checkInfo);
    passwordController.addListener(_checkInfo);
    portController.addListener(_checkInfo);
  }

  _showMaterialAlertDialog(BuildContext ctx, String caption, Widget content) {
    return showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(caption),
            content: Expanded(
              child: SingleChildScrollView(
                child: content,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        });
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
          _showMaterialAlertDialog(
              ctx, '登录失败', Text(error.toString() + '\n\n请检查端口号!'));
          setState(() {
            _isLoading = false;
          });
        })
        .then((response) {
          setState(() {
            _isLoading = false;
          });
          if (response.statusCode == 200) {
            var body = json.decode(response.body);
            _showMaterialAlertDialog(
                ctx,
                '登录成功',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('token: ' + body['token'] + '\n'),
                    Text('username: ' + body['username'])
                  ],
                ));
          } else {
            _showMaterialAlertDialog(
              ctx,
              '登录失败',
              Text('Error: ' +
                  (response.body.isEmpty
                      ? '未知错误：${response.statusCode}'
                      : response.body)),
            );
            // Text('Error: ' + body["non_field_errors"][0]));
          }
        });
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
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                  child: const Text(
                    '卡卡随心游LOGO',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                  )),
              // const SizedBox(height: 40,)
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  controller: portController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: '端口号',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: '用户名/手机号',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                height: 60,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                      : const Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                  // The button would be disabled if onPress is null.
                  onPressed: _disableButton ? null : () => _login(context),
                ),
              ),
              Row(
                children: <Widget>[
                  const Text('还没有卡卡账户？'),
                  SizedBox(
                    width: 48,
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
                    width: 100,
                    child: TextButton(
                      // textColor: Colors.blue,
                      child: const Text(
                        '使用微信登录', // TODO: 替换成微信图标
                        // style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {}, // TODO
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
