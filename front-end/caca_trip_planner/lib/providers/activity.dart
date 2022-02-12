import 'package:flutter/material.dart';
import './location.dart';

class Activity extends ChangeNotifier {
  /// for transportation, locationId is -1
  final String locationId;

  final DateTime startTime;
  final DateTime endTime;
  final int duration; // minutes
  final double cost; // CNY
  String remarks;

  Location? location;
  // following fields are the same as in Location object
  final LocationType type;
  final String name; // See reserved names at the end.

  // following fields are reserved for future use
  String? id;
  String? tripId;
  String? destinationId;

  Activity({
    required this.locationId,
    required this.startTime,
    required this.endTime,
    required this.cost,
    required this.type,
    required this.name,
    required this.remarks,
    required this.duration,
    this.tripId,
    this.id,
    this.destinationId,
    this.location,
  });
}

// Following are reserved names for transportation. Each matches an icon.
// 骑自行车、骑电动车、步行、打车、公交、地铁、驾车、轮渡、电车、索道
