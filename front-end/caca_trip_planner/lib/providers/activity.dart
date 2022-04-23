import 'package:flutter/material.dart';
import './location.dart';

/// Activity relies on Location. So it must be initialized with a ProxyProvider!
/// Example:
/// ```dart
/// // We use ChangeNotifierProxyProvider here because Activity is a ChangeNotifer.
/// ChangeNotifierProxyProvider<Location, Activity>(
/// // First, create an Activity using a previously provided Location.
/// create: (context) => Activity(location: loc, ...,),
/// // Next, define a function to be called when location updates
/// update: (context, newLoc, oldAct) => Activity(location: newLoc, ...,),
/// );
/// ```
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
    this.location,
    this.tripId,
    this.id,
    this.destinationId,
  });

  Map toJson() => {
        'locationId': locationId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'name': name,
        'type': type.toChineseString(),
        'duration': duration,
        'cost': cost,
        'remarks': remarks,
        if (tripId != null) 'tripId': tripId,
        if (id != null) 'id': id,
        if (destinationId != null) 'destinationId': destinationId,
      };
}

// Following are reserved names for transportation. Each matches an icon.
// 骑自行车、骑电动车、步行、打车、公交、地铁、驾车、轮渡、电车、索道
