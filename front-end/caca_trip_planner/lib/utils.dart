import 'package:flutter/material.dart';

class Utils {
  static dynamic showMaterialAlertDialog(
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
        });
  }
}
