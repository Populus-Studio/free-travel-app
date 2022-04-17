import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/cable_car_icon_icons.dart';

/// This is a class that largely handles authentication services, and also
/// stores some global variables.
class Utils {
  /// Height of iPhone 13 Pro Max. Serves as reference.
  static const double h13pm = 926.0;

  /// Width of iPhone 13 Pro Max. Servers as reference.
  static const double w13pm = 428.0;

  /// Authority (domain + port) address of server.
  static const authority = '152.136.233.65:80';

  /// Add following header for authentication.
  static Map<String, String> get authHeader =>
      {HttpHeaders.authorizationHeader: 'Bearer $_token'};

  /// This is needed when sending requests with a body of a json string.
  static get jsonHeader => {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json"
      };

  // TODO: Delete this debug token and username
  static String _token = '';
  static String _username = 'huyang';

  /// Time for a token to expire.
  static const expiryDuration = Duration(days: 1);

  /// Timer for auto logout.
  static Timer? _authTimer;

  /// Check login status
  static bool get isAuth => _token.isNotEmpty;

  /// Token getter. Because it shouldn't be changed from outside!
  static String get token => _token;

  /// Username getter.
  static String get username => _username;

  /// Random number generator.
  static final Random rng = Random();

  /// Displays a classic material style dialog.
  static Future<Object?> showMaterialAlertDialog(
      BuildContext ctx, String caption, Widget content) {
    return showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(caption),
          content: SingleChildScrollView(
            child: content,
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
      },
    );
  }

  /// Post user behavior such as selected a site, etc. This method does not
  /// throw error because it is not imperative.
  static void postUserBehavior({
    required siteId,
    required selected,
    behaviorType = 0, // 0 for selecting behavior
    behaviorWeight = 0,
    contextLocation = '',
  }) async {
    await http.post(
      Uri.http(Utils.authority, '/user/behavior/'),
      headers: Utils.authHeader..addAll(Utils.jsonHeader),
      body: json.encode({
        'username': Utils.username,
        'siteId': siteId,
        'behaviorType': behaviorType,
        'contextTime': DateTime.now().toIso8601String(),
        'contextLocation': contextLocation,
        'behaviorBool': selected ? 0 : 1,
        'behaviorWeight': behaviorWeight,
      }),
    );
  }

  /// Following methods are for authentication purposes.

  /// This method sends a login request. Currently it only supports loggin in
  /// via username and password.
  static Future<bool> sendLoginRequest(
      {String? username, String? password, autoRenew = true}) async {
    if (username == null || password == null) return false;
    // login
    final response = await http.post(
      Uri.http(Utils.authority, '/auth/login/registered'),
      body: json.encode({
        'username': username,
        'password': password,
      }),
      headers: jsonHeader,
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      _token = body['token'];
      username = username; // FIXME: Might need fix
      print(_token);
      final userData = {
        'token': _token,
        'username': username,
        'password': password,
        'expiraryDate':
            DateTime.now().add(Utils.expiryDuration).toIso8601String(),
      };
      // update login info
      updateUserData(data: userData, autoRenew: autoRenew);
      return true;
    } else {
      return false;
    }
  }

  /// An interactive login service (that can only be called from a widget tree).
  /// Code duplication with sendLoginRequest() exists for interactive purposes.
  /// Currently it only supports logging in via username and password.
  static Future<bool> login(
      {required BuildContext context,
      String? username,
      String? password,
      autoRenew = true,
      FutureOr<dynamic> Function(Object?)? nextStep}) async {
    if (username == null || password == null) return false;
    final response = await http
        .post(
          Uri.http(Utils.authority, '/auth/login/registered'),
          body: json.encode({
            'username': username,
            'password': password,
          }),
          headers: jsonHeader,
        )
        .timeout(const Duration(seconds: 3))
        .catchError((error) {
      showMaterialAlertDialog(
          context, '登录失败', Text(error.toString() + '\n\n请检查端口号!'));
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      _token = body['token'];
      username = username; // FIXME: Might need fix
      print(_token);
      final userData = {
        'token': _token,
        'username': username,
        'password': password,
        'expiryDate':
            DateTime.now().add(Utils.expiryDuration).toIso8601String(),
      };
      updateUserData(data: userData, autoRenew: autoRenew);
      showMaterialAlertDialog(
        context,
        '登录成功',
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('token: ' + body['token'] + '\n'),
            Text('username: ' + body['username'])
          ],
        ),
      ).then(nextStep ?? (_) => Navigator.of(context).pop());
      return true;
    } else {
      showMaterialAlertDialog(
          context,
          '登录失败',
          response.body.isEmpty
              ? Text('未知错误：${response.statusCode}')
              : const Text('用户名或密码有误！'));
      return false;
    }
  }

  /// A renew token service.
  static Future<bool> _renewToken() async {
    // get login info
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) return false;

    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, String>;
    final password = userData['password']!;

    // login
    return sendLoginRequest(
      username: _username,
      password: password,
      autoRenew: true,
    );
  }

  /// Register user auth data and set up auto-renew service.
  static Future<void> updateUserData(
      {required Map<String, String> data, autoRenew = true}) async {
    // update global variable
    _token = data['token']!;
    _username = data['username']!;

    // write to disk
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', json.encode(data));

    // Set up auto renew. See _autoLogout() for a different way of setting up
    // a timer.
    if (autoRenew) {
      Future.delayed(expiryDuration, _renewToken);
    }

    _autoLogout();
  }

  /// This method should be called every time after logging in. It is called in
  /// updateUserData() now which is called after every login.
  static Future<bool> _autoLogout() async {
    // cancel existing timer
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    // set up new timer
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']!);
    // expire 2 seconds before renewing
    final timeToExpiry = expiryDate
        .difference(DateTime.now().subtract(const Duration(seconds: 2)))
        .inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    return true;
  }

  /// Log out method. When explicitly called by user, set deleteCache: true for
  /// better security. Otherwise, deleteCache is by default false so as to
  /// enable auto login and auto token renewing.
  static Future<void> logout({deleteCache = false}) async {
    _token = '';
    _username = '';
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    if (deleteCache) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('userData');
    }
  }

  /// Try auto-login (e.g. at app start up).
  static Future<bool> tryAutoLogin() async {
    // get user data
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, String>;
    if (DateTime.parse(userData['expiryDate']!).isBefore(DateTime.now())) {
      return false;
    }

    // try auto login
    final _username = userData['username'];
    final _password = userData['password'];
    return sendLoginRequest(username: _username, password: _password);
  }
}

extension Validator on String {
  bool isValidPort() {
    return RegExp(r'^[0-9]{1,4}$').hasMatch(this);
  }

  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool isValidPhoneNumber() {
    return RegExp(r'^1[0-9]{10}$').hasMatch(this);
  }

  bool isValidPassword() {
    return length >= 8;
  }

  IconData toTransportationIcon() {
    // Following are reserved names for transportation. Each matches an icon.
    // 骑自行车、骑电动车、步行、打车/驾车、公交、地铁、轮渡、电车、索道
    switch (this) {
      case '骑自行车':
        return Icons.directions_bike;
      case '骑电动车':
        return Icons.bike_scooter;
      case '步行':
        return Icons.directions_walk;
      case '打车':
      case '驾车':
        return Icons.directions_car;
      case '公交':
        return Icons.directions_bus;
      case '地铁':
        return Icons.directions_subway;
      case '轮渡':
        return Icons.directions_ferry;
      case '电车':
        return Icons.tram;
      case '索道':
        return CableCarIcon.iconData;
      default:
        return Icons.rocket;
    }
  }
}

extension DateFormatter on DateTime {
  /// This will return strings like '1年前', '5.20', or '今天' depending on the date.
  String toChineseString() {
    final now = DateTime.now();
    if (year < now.year) {
      return '${now.year - year} 年前';
    } else if ((day - now.day).abs() < 3) {
      switch (day - now.day) {
        case 2:
          return '后天';
        case 1:
          return '明天';
        case 0:
          return '今天';
        case -1:
          return '昨天';
        case -2:
          return '前天';
        default:
          return toString();
      }
    } else {
      return toString().substring(5, 10); // extract date and month
    }
  }
}

/// A parameter to pass to the toChineseDurationString() method in IntExtension,
/// telling the method which measurement the original integer is under. For now,
/// only the minute measurement is used in this app, so this enum is here only
/// for expandibility.
enum TimeMeasure {
  minute, // 分钟
}

extension IntExtension on int {
  /// This will return an appropriate duration string based on the number of
  /// minutes in a duration. For example,
  /// ```dart
  /// 90.toChineseString(measure: TimeMeasure.minute);
  /// ```
  /// will yield '1.5 个小时'.
  String toChineseDurationString({TimeMeasure measure = TimeMeasure.minute}) {
    switch (measure) {
      case TimeMeasure.minute:
        {
          if (this < 60) {
            return '$this 分钟';
          } else {
            // longer than 60 minutes
            final double numOfHours = this / 60.0;
            if (numOfHours % 1 == 0) {
              // if there's no decimal digits
              return '${numOfHours.round()} 个小时';
            } else {
              return '${numOfHours.toStringAsFixed(1)} 个小时';
            }
          }
        }
      default:
        return '未知时长';
    }
  }
}

extension ColorExtension on Color {
  /// Darken a color by a certain amount.
  Color darken({double amount = .1}) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Lighten a color by a certain amount.
  Color lighten({double amount = .1}) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

/// For obtaining the absolute position of a widget on screen.
extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
