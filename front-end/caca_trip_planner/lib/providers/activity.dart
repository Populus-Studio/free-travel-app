import 'package:flutter/material.dart';

class Activity extends ChangeNotifier {
  // TODO: implement Activity model
  final int duration; // minutes
  final String tripId;

  Activity({
    required this.duration,
    required this.tripId,
  });
}
