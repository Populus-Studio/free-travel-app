import 'package:flutter/material.dart';

import 'select_screen.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({Key? key}) : super(key: key);
  static const routeName = '/plan-screen';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text("选择地点"),
        onPressed: () {
          Navigator.of(context).pushNamed(SelectScreen.routeName);
        },
      ),
    );
  }
}
