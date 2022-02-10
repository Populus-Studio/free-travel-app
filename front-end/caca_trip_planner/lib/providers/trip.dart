import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Trip extends ChangeNotifier {
  final String id;
  final String name;
  final String type;
  final String description;
  final String departureId;
  final int numOfTourists;
  final DateTime startDate;
  final DateTime endDate;
  final int duration; // days
  final List<String> activityIds;
  final int totalActivities;
  final int totalCost;
  final String remarks;

  late String coverLocationId;

  Trip({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.departureId,
    required this.numOfTourists,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.activityIds,
    required this.totalActivities,
    required this.totalCost,
    required this.remarks,
  }) {
    // determine cover location
    // 1. find longest-lasting activity
    // 2. find its location
    // 3. use the location's image as cover image of the trip
    // activities =
    // int maxActTime= 0;
    // String maxActId = '';
  }
}
