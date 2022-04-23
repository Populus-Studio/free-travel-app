import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({Key? key}) : super(key: key);
  static const routeName = '/my-screen';

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Screen',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }
}
