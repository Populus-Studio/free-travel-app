import 'package:cacatripplanner/providers/activity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './location.dart';

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

  void updateCoverLocationId() {
    coverLocationId =
        activities.reduce((a, b) => a.duration > b.duration ? a : b).locationId;
  }

  static Trip fromJsonBody(dynamic body) {
    final List<Activity> activities = (body['activities'] as List<dynamic>)
        .map(
          (act) => Activity(
            locationId: act['id'],
            startTime: DateTime.parse(act['startTime']),
            endTime: DateTime.parse(act['endTime']),
            cost: act['cost'],
            type: LocationTypeExtension.fromString(act['type']),
            name: act['name'],
            remarks: act['remarks'],
            duration: act['duration'],
          ),
        )
        .toList();
    final Trip trip = Trip(
      id: body['id'],
      name: body['name'],
      description: body['description'],
      departureId: body['departureId'],
      numOfTourists: body['numOfTourists'],
      startDate: DateTime.parse(body['startDate']),
      endDate: DateTime.parse(body['endDate']),
      duration: body['duration'],
      activities: activities,
      totalCost: body['totalCost'],
      remarks: body['remarks'],
    );
    return trip;
  }
}
