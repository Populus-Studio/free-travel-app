import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:vibration/vibration.dart';

class Utils {
  static const double h13pm = 926.0;
  static const double w13pm = 428.0;
  static const authority = '152.136.233.65:80'; // authority is domain + port
  // TODO: Delete this debug token
  static String token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo5LCJ1c2VybmFtZSI6Imh1eWFuZyIsImV4cCI6MTY0NDY4MTMwOCwiZW1haWwiOiIifQ.rjFaCWNFW9n0BLpKBSIGQEI-wsbAYRMA1Gi-0gPhJWA';
  static final Random rng = Random();

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

  Icon toTransportationIcon() {
    // Following are reserved names for transportation. Each matches an icon.
// 骑自行车、骑电动车、步行、打车、公交、地铁、驾车、轮渡、电车、索道
    switch (this) {
      default:
        return const Icon(Icons.rocket);
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
  /// will yield '1.5小时'.
  String toChineseDurationString({TimeMeasure measure = TimeMeasure.minute}) {
    switch (measure) {
      case TimeMeasure.minute:
        {
          if (this < 30) {
            return '$this 分钟';
          } else {
            // longer than 30 minutes
            final double numOfHours = this / 60.0;
            if (numOfHours % 1 == 0) {
              // if there's not decimal digits
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
