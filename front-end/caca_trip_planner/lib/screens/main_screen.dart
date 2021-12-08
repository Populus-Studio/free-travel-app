import 'package:cacatripplanner/screens/login_screen.dart';
import 'package:cacatripplanner/screens/singup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/select_screen.dart';
import '/providers/locations.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/main-screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              child: const Text("注册"),
              onPressed: () {
                Navigator.of(context).pushNamed(SignupScreen.routeName);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text("登录"),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(LoginViaUsernameScreen.routeName);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text("选择地点"),
              onPressed: () {
                Provider.of<Locations>(context, listen: false)
                    .loadImages()
                    .then((_) {
                  Navigator.of(context).pushNamed(SelectScreen.routeName);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
