import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class Utils {
  static const double h13pm = 926.0;
  static const double w13pm = 428.0;

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
