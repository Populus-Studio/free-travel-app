import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const url = 'https://192.168.0.1/'; // TODO: 改用真实URL

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  _createAlertDialog(BuildContext context, String caption, Widget content) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(caption),
            content: content,
            actions: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('OK'),
              )
            ],
          );
        });
  }

  void _login(BuildContext context) {
    http
        .post(Uri.parse(url + '/auth/login/registered'),
            body: json.encode({
              'phoneNumber': nameController.text,
              'password': passwordController.text,
            }))
        .then((response) {
      var body = json.decode(response.body);
      if (response.statusCode == 200) {
        _createAlertDialog(
            context,
            '登录成功！',
            Column(
              children: [
                Text('token: ' + body['token']),
                Text('username: ' + body['username'])
              ],
            ));
      } else {
        _createAlertDialog(context, '登录失败！', Text('Response Body: ' + body));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('密码登录'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                // const SizedBox(
                //   height: 40,
                // ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                    child: const Text(
                      '卡卡随心游',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                    )),
                // const SizedBox(height: 40,)
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '手机号',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '密码',
                    ),
                  ),
                ),
                Container(
                  // padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  // alignment: Alignment.bottomRight,
                  child: Row(
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
                  // height: 50,
                ),
                Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: ElevatedButton(
                      // textColor: Colors.white,
                      // color: Colors.blue,
                      child: const Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () => _login(context),
                    )),
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
                        onPressed: () {
                          //signup screen
                        },
                      ),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )
              ],
            )));
  }
}

// test github 2
