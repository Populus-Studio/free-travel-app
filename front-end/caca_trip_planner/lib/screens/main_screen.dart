import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/select_screen.dart';
import '/providers/locations.dart';
import '/utils.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/main-screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text("选择地点"),
            onPressed: () {
              Provider.of<Locations>(context, listen: false)
                  .loadImages()
                  .then((_) {
                Navigator.of(context).pushNamed(SelectScreen.routeName);
              });
            },
          )),
    );
  }
}
