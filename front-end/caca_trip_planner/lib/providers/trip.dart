import 'dart:convert';

import 'package:cacatripplanner/providers/activity.dart';
import 'package:cacatripplanner/providers/location.dart';
import 'package:flutter/material.dart';

class Trip extends ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final int departureId;
  final int numOfTourists;
  final DateTime startDate;
  final DateTime endDate;
  final int duration; // days
  final List<Activity> activities;
  final int totalCost;
  final String remarks;
  final bool isFavorite;

  /// name of the creator of this trip
  final String username;

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
    required this.isFavorite,
    required this.username,
    this.coverLocationId,
  }) {
    // determine cover location
    if (coverLocationId == null) {
      updateCoverLocationId();
    }
  }

  /// Note that the 'activites' field is a "\<string\>: \<string\>" (but not a
  /// "\<string\>: \<nested json list\>" field), the value being the nested json
  /// string of the list of activites. This anomaly is to accommodate a relevant
  /// API design. Example:
  /// ```json
  /// "activities":"[{\"locationId\":\"49\",\"startTime\":\"2022-02-11T08:00:00.000\",\"endTime\":\"2022-02-11T10:30:00.000\",\"name\":\"什刹海\",\"type\":\"景点\",\"duration\":150,\"cost\":50.0,\"remarks\":\"早上去人少\"},{\"locationId\":\"-1\",\"startTime\":\"2022-02-11T10:30:00.000\",\"endTime\":\"2022-02-11T11:00:00.000\",\"name\":\"打车\",\"type\":\"交通\",\"duration\":30,\"cost\":40.0,\"remarks\":\"\"},{\"locationId\":\"65\",\"startTime\":\"2022-02-11T11:00:00.000\",\"endTime\":\"2022-02-11T11:30:00.000\",\"name\":\"天安门广场\",\"type\":\"地标\",\"duration\":30,\"cost\":0.0,\"remarks\":\"必去，在外围逛逛就好\"}
  /// ```
  Map toJson() {
    // final List<Map> activityJsonMap = activities.map((a) => a.toJson()).toList();
    final activityJsonString = jsonEncode(activities);
    return {
      'id': id,
      'name': name,
      'description': description,
      'departureId': departureId,
      'numOfTourists': numOfTourists,
      'startDate': startDate.toIso8601String().substring(0, 10), // 'yyyy-mm-dd'
      'endDate': endDate.toIso8601String().substring(0, 10),
      'duration': duration,
      'activities': activityJsonString,
      'remarks': remarks,
      'isFavorite': isFavorite,
      'username': username,
    };
  }

  Image getCoverImage() {
    updateCoverLocationId();
    final act = activities.firstWhere((a) => a.locationId == coverLocationId);
    return act.location!.img;
  }

  Location getCoverLocation() {
    // FIXME: To attend to a back-end bug
    return activities
        .firstWhere((a) =>
            a.locationId == coverLocationId &&
            a.type != LocationType.transportation)
        .location!;
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
