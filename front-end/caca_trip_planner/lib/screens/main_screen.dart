import 'package:cacatripplanner/helpers/dummy_data.dart';
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

class MainScreen extends StatefulWidget {
  static const routeName = '/main-screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _tripIdController = TextEditingController();

  String tripId = '19';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TripCard(id: tripId, key: GlobalKey()),
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
                if (Utils.isAuth) {
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
            ElevatedButton(
              child: const Text('postTrip()'),
              onPressed: () => Provider.of<Trips>(context, listen: false)
                  .postTrip(DummyData.dummyTrips[0]),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _tripIdController,
                decoration: const InputDecoration(labelText: '测试行程 ID'),
              ),
            ),
            ElevatedButton(
              child: const Text('clear ALL cache && fetch trip'),
              onPressed: () {
                Provider.of<Trips>(context, listen: false).clearAllCache();
                Provider.of<Locations>(context, listen: false).clearAllCache();
                Provider.of<Trips>(context, listen: false)
                    .fetchTripById(_tripIdController.text, test: false)
                    .then((_) {
                  Utils.showMaterialAlertDialog(context, '获取行程成功', Container());
                  setState(() {
                    tripId = _tripIdController.text;
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
