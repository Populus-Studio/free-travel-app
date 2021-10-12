import 'package:flutter/material.dart';
import 'package:logintunisia/screens/login_via_username_screen.dart';
import 'package:logintunisia/screens/singup_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '卡卡随心游',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              accentColor: Colors.amber,
              primarySwatch: Colors.pink,
              backgroundColor: const Color.fromRGBO(255, 254, 229, 1)),
          fontFamily: 'Raleway',
          textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: const TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              bodyText2: const TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              caption: const TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ))),
      initialRoute: LoginViaUsernameScreen.routeName,
      routes: {
        LoginViaUsernameScreen.routeName: (ctx) =>
            const LoginViaUsernameScreen(),
        SignupScreen.routeName: (ctx) => const SignupScreen(),
      },
    );
  }
}
