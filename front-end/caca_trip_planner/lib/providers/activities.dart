import 'package:flutter/material.dart';

import './activity.dart';

class Activities extends ChangeNotifier {
  final List<Activity> _activityPool = [];

  List<Activity> ofTrip(String tripId) {
    return _activityPool.where((act) => act.tripId == tripId).toList();
  }
}
