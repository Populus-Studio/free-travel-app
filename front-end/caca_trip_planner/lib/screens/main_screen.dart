import 'package:cacatripplanner/helpers/sticky_note.dart';
import 'package:cacatripplanner/providers/trips.dart';
import 'package:cacatripplanner/screens/login_screen.dart';
import 'package:cacatripplanner/screens/singup_screen.dart';
import 'package:cacatripplanner/utils.dart';
import 'package:cacatripplanner/widgets/trip_card.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const TripCard(id: '19'),
            ElevatedButton(
              child: const Text("注册"),
              onPressed: () {
                Navigator.of(context).pushNamed(SignupScreen.routeName);
              },
            ),
            ElevatedButton(
              child: const Text("登录"),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(LoginViaUsernameScreen.routeName);
              },
            ),
            ElevatedButton(
              child: const Text("选择地点"),
              onPressed: () {
                // if user did not sign in
                if (Utils.token == '') {
                  Utils.showMaterialAlertDialog(
                      context, '请登录', const Text('您需要先登录才能访问此项功能'));
                  return;
                }
                // With FutureBuilder, there's no need to do pre-fetching here.
                // Provider.of<Locations>(context, listen: false)
                //     .loadImages(num: 2, type: 2) // preload images
                //     .then((_) {
                //   Navigator.of(context).pushNamed(SelectScreen.routeName);
                // });
                Navigator.of(context).pushNamed(SelectScreen.routeName);
              },
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: StickyNote(
                child: Container(),
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
