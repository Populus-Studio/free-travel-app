import 'package:cacatripplanner/providers/activity.dart';
import 'package:cacatripplanner/providers/location.dart';
import 'package:flutter/material.dart';

class Trip extends ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final String departureId;
  final int numOfTourists;
  final DateTime startDate;
  final DateTime endDate;
  final int duration; // days
  final List<Activity> activities;
  final int totalCost;
  final String remarks;

  String? coverLocationId;

  Trip({
    required this.id,
    required this.name,
    required this.description,
    required this.departureId,
    required this.numOfTourists,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.activities,
    required this.totalCost,
    required this.remarks,
    this.coverLocationId,
  }) {
    // determine cover location
    if (coverLocationId == null) {
      updateCoverLocationId();
    }
  }

  Image getCoverImage() {
    updateCoverLocationId();
    final act = activities.firstWhere((a) => a.locationId == coverLocationId);
    return act.location.img;
  }

  Location getCoverLocation() {
    return activities
        .firstWhere((a) => a.locationId == coverLocationId)
        .location;
  }

  void updateCoverLocationId() {
    coverLocationId = activities.reduce((a, b) {
      // ignore transportation activities
      if (a.type == LocationType.transportation) {
        return b;
      } else if (b.type == LocationType.transportation) {
        return a;
      } else {
        return a.duration > b.duration ? a : b;
      }
    }).locationId;
    notifyListeners();
  }
}
