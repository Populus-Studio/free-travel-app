import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:debounce_throttle/debounce_throttle.dart';

const url = 'http://152.136.233.65:';
const jsonHeaders = {
  "Accept": "application/json",
  "content-type": "application/json"
};

class SignupScreen extends StatefulWidget {
  static const routeName = '/auth/signup';

  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isChecked = false;
  bool _isValidInfo = false; // 不用get是因为_isValidInfo在一次build中多次被访问，尽量减少开销。
  bool _hasDuplicateUsername = false;
  bool get _isLegalPhoneNumber => _checkPhoneNumber();
  bool get _disableButton => _isLoading == true || _isValidInfo == false;
  final nameDebouncer = Debouncer<String>(
    const Duration(milliseconds: 100),
    initialValue: '',
  );

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    portController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    nameController.addListener(() {
      nameDebouncer.value = nameController.text;
    });
    nameDebouncer.values.listen((username) {
      _checkDuplicateUsername(); // 该函数中间接调用了setState()
    });
    portController.addListener(_checkInfo);
    phoneController.addListener(_checkInfo);
    passwordController.addListener(_checkInfo);
  }

  void _checkInfo() {
    setState(() {
      _isValidInfo = portController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          !_hasDuplicateUsername &&
          _isLegalPhoneNumber &&
          passwordController.text.isNotEmpty &&
          _isChecked;
    });
  }

  void _checkDuplicateUsername() {
    http
        .get(Uri.parse(
            '$url${portController.text}/auth/check/username?username=${nameDebouncer.value}'))
        .then((response) {
      if (response.statusCode == 200) {
        _hasDuplicateUsername = json.decode(response.body)['result'];
      } else {
        _hasDuplicateUsername = false;
      }
      _checkInfo();
    });
  }

  bool _checkPhoneNumber() {
    return phoneController.text.isEmpty ||
        (phoneController.text.isNotEmpty && phoneController.text.length == 11);
  }

  void _signup(BuildContext ctx) {
    setState(() {
      _isLoading = true;
    });

    http
        .post(
          Uri.parse(url + portController.text + '/auth/register'),
          body: json.encode({
            'username': nameController.text,
            if (phoneController.text.isNotEmpty)
              'phoneNumber': phoneController.text,
            'password': passwordController.text,
          }),
          headers: jsonHeaders,
        )
        .timeout(const Duration(seconds: 3),
            onTimeout: () => _showMaterialAlertDialog(
                ctx, '注册失败', const Text('请求超时' '\n\n请检查端口号!')))
        .catchError((error) {
      _showMaterialAlertDialog(
          ctx, '注册失败', Text(error.toString() + '\n\n请检查端口号!'));
      setState(() {
        _isLoading = false;
      });
    }).then((response) {
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var body = json.decode(response.body);
        _showMaterialAlertDialog(
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
            ));
      } else if (response.statusCode == 409) {
        var body = json.decode(response.body);
        // Check if has duplicate phone number.
        if ((body['msg'] as String).contains('phone')) {
          _showMaterialAlertDialog(
            ctx,
            '注册失败',
            const Text('手机号已存在！'),
          );
        } else if ((body['msg'] as String).contains('name')) {
          _showMaterialAlertDialog(
            ctx,
            '注册失败',
            const Text('用户名已存在！'),
          );
        }
      } else {
        _showMaterialAlertDialog(
          ctx,
          '注册失败',
          Text('Error: ' +
              (response.body.isEmpty
                  ? '未知错误：${response.statusCode}'
                  : response.body)),
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('注册'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                  child: const Text(
                    '卡卡随心游LOGO',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                  )),
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
                    labelText: _hasDuplicateUsername ? '用户名 - 用户名已存在！' : '用户名',
                    floatingLabelStyle: _hasDuplicateUsername
                        ? TextStyle(color: Theme.of(context).errorColor)
                        : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  controller: phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText:
                        _isLegalPhoneNumber ? '手机号（可选）' : '手机号（可选）- 手机号不合法',
                    floatingLabelStyle: !_isLegalPhoneNumber
                        ? TextStyle(color: Theme.of(context).errorColor)
                        : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: '密码',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 25,
                    child: Checkbox(
                      onChanged: (val) {
                        _isChecked = val ?? false;
                        _checkInfo();
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
                    onTap: () => _showMaterialAlertDialog(
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
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
    );
  }
}
