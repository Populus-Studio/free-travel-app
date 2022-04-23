import 'dart:convert';

import 'package:cacatripplanner/helpers/dummy_data.dart';
import 'package:cacatripplanner/providers/trips.dart';
import 'package:cacatripplanner/screens/my_screen.dart';
import 'package:cacatripplanner/screens/plan_screen.dart';
import 'package:cacatripplanner/screens/tabs_screen.dart';
import 'package:cacatripplanner/screens/test_screen.dart';
import 'package:cacatripplanner/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:wechat_kit/wechat_kit.dart';

import './screens/select_screen.dart';
import './screens/login_screen.dart';
import './screens/main_screen.dart';
import './screens/singup_screen.dart';
import './providers/location.dart';
import './providers/locations.dart';
import './utils.dart';

// const String WECHAT_APPID = 'wx65d1559cb410594a';
// const String WECHAT_UNIVERSAL_LINK = 'We don\'t have a link yet...';
// const String WECHAT_APPSECRET = '7c1e471230e737033f862f5f1f4119ff';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // Wechat.instance.registerApp(
  //   appId: WECHAT_APPID,
  //   universalLink: WECHAT_UNIVERSAL_LINK,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Locations()),
        ChangeNotifierProxyProvider<Locations, Trips>(
          create: (context) => Trips(
            // we can set listen: false because create is only called once
            Provider.of<Locations>(context, listen: false),
          ),
          update: (context, locations, oldTrips) => Trips(locations),
        ),
      ],
      child: MaterialApp(
        title: '卡卡随心游',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            accentColor: Colors.amber,
            primarySwatch: Colors.indigo,
            backgroundColor: const Color.fromRGBO(255, 254, 229, 1),
          ),
          // fontFamily: 'Raleway',
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyText1: const TextStyle(
                  color: Colors.white,
                ),
                bodyText2: const TextStyle(
                  color: Colors.white,
                ),
                caption: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                headline1: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                headline2: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                headline3: const TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                ),
                // TODO: Add textTheme for: heading1
              ),
        ),
        home: const TabsScreen(),
        routes: {
          SignupScreen.routeName: (context) => const SignupScreen(),
          MainScreen.routeName: (context) => const MainScreen(),
          LoginViaUsernameScreen.routeName: (context) =>
              const LoginViaUsernameScreen(),
          SelectScreen.routeName: (context) => const SelectScreen(),
          TripScreen.routeName: (context) => const TripScreen(),
          TabsScreen.routeName: (context) => const TabsScreen(),
          MyScreen.routeName: (context) => const MyScreen(),
          PlanScreen.routeName: (context) => const PlanScreen(),
          TestScreen.routeName: (context) => const TestScreen(),
        },
      ),
    );
  }
}

// 发布安卓APK： flutter build apk --split-per-abi
// Find SHA1: in /android, execute ./gradlew signingReport
// Find package ID: android/app/src/main/AndroidManifest.xml
// 高德地图iOS key：4e476f4114795793a2f757f8c4b8823e
// 高德地图Android key：5004019091f8700a3c091433c50e6fb9
