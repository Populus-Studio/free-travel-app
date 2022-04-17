// 屎山警告！切勿随意改动布局！
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:wechat_kit/wechat_kit.dart';

import '../screens/main_screen.dart';
import '../screens/singup_screen.dart';
import '../screens/tabs_screen.dart';
import '../utils.dart';

class LoginViaUsernameScreen extends StatefulWidget {
  static const routeName = '/auth/login-via-username';

  const LoginViaUsernameScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<LoginViaUsernameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // TextEditingController portController = TextEditingController();
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

    _nameController.addListener(_checkInfo);
    _passwordController.addListener(_checkInfo);
    // portController.addListener(_checkInfo);
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
      _isValidInfo =
          // portController.text.isNotEmpty &&
          _nameController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty;
    });
  }

  void _login(BuildContext ctx) async {
    setState(() {
      _isLoading = true;
    });

    await Utils.login(
        context: ctx,
        username: _nameController.text,
        password: _passwordController.text,
        nextStep: (_) => Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : Navigator.pushReplacementNamed(context, TabsScreen.routeName));

    setState(() {
      _isLoading = false;
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
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                  ),
                  onPressed: () => Navigator.of(context).pop())
              : null,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20 * rh,
              ),
              const Text(
                '登录',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 40,
                  color: Colors.black87,
                ),
              ),
              Image(
                image: const AssetImage('assets/icons/icon.png'),
                height: 160 * rh,
                width: 160 * rh,
              ),
              Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 8.0,
                  child: SizedBox(
                    width: 380 * rw,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * rw,
                              vertical: 10 * rh,
                            ),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10 * rh),
                                ),
                                labelText: '用户名/手机号',
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                10 * rw, 10 * rh, 10 * rw, 0),
                            child: TextField(
                              obscureText: true,
                              controller: _passwordController,
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
                          // Row(
                          //   children: [
                          //     TextButton(
                          //       onPressed: () {},
                          //       child: const Text('使用其它方式登录'),
                          //     ),
                          //     TextButton(
                          //       onPressed: () {
                          //         //forgot password screen
                          //       },
                          //       // textColor: Colors.blue,
                          //       child: const Text('忘记密码'),
                          //     ),
                          //   ],
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // ),
                          Container(
                            width: double.infinity,
                            height: 60 * rh,
                            padding: EdgeInsets.fromLTRB(
                                10 * rw, 10 * rh, 10 * rw, 0),
                            child: ElevatedButton(
                              // textColor: Colors.white,
                              // color: Colors.blue,
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
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
                              onPressed:
                                  _disableButton ? null : () => _login(context),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                // textColor: Colors.blue,
                                child: const Text(
                                  '注册',
                                  // style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () => _goToSingupScreen(context),
                              ),
                              // SizedBox(
                              //   width: 90 * rw,
                              //   child: TextButton(
                              //     // textColor: Colors.blue,
                              //     child: const Text(
                              //       '环境检查', // TODO: 替换成微信图标
                              //       // style: TextStyle(fontSize: 20 * rw),
                              //     ),
                              //     onPressed: () async {
                              //       // final String content =
                              //       //     'wechat: ${await Wechat.instance.isInstalled()} - ${await Wechat.instance.isSupportApi()}';
                              //       //   Utils.showMaterialAlertDialog(
                              //       //       context, '环境检查', Text(content));
                              //     }, // TODO
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 90 * rw,
                              //   child: TextButton(
                              //     // textColor: Colors.blue,
                              //     child: const Text(
                              //       '微信登录', // TODO: 替换成微信图标
                              //       // style: TextStyle(fontSize: 20 * rw),
                              //     ),
                              //     onPressed: () {
                              //       // Wechat.instance.auth(
                              //       //   scope: <String>[WechatScope.SNSAPI_USERINFO],
                              //       //   state: 'auth',
                              //       // );
                              //     },
                              //   ),
                              // ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
