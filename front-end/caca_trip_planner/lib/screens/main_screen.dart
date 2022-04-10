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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
