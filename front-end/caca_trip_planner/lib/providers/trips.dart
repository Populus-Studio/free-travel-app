import 'dart:convert';
import 'dart:io';
import 'package:cacatripplanner/helpers/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;

import './trip.dart';
import './activity.dart';
import './location.dart';
import '../utils.dart';
import './locations.dart';

class Trips extends ChangeNotifier {
  /// This is for testing purposes, which uses dummy data instead.
  static const bool testMode = true;

  // Simply because we need to fetch Locations when initializing a trip,
// Trips is a ProxyProvider that needs to have access to Locations.
  Locations locations;

  Trips(this.locations, {Trips? oldTrips}) {
    if (oldTrips != null) {
      _tripPool = oldTrips._tripPool;
      _favoriteTrips = oldTrips._favoriteTrips;
      _finishedTrips = oldTrips._finishedTrips;
      _futureTrips = oldTrips._futureTrips;
      _ongoingTrips = oldTrips._ongoingTrips;
      _recommendedTrips = oldTrips._recommendedTrips;
    }
  }

  /// This pool saves all cached trips.
  List<Trip> _tripPool = [];

  // Following lists save catagorized cached trips.
  List<Trip> _favoriteTrips = [];
  List<Trip> _finishedTrips = [];
  List<Trip> _ongoingTrips = [];
  List<Trip> _futureTrips = [];
  List<Trip> _recommendedTrips = [];

  Future<Trip> createTrip({
    required String name,
    required String description,
    required String departureId,
    required int numOfTourists,
    required DateTime startDate,
    required DateTime endDate,
    required int duration,
    required List<String> locationIds,
    required int totalCost,
    required String remarks,
  }) async {
    if (testMode) {
      // FIXME
      return DummyData.dummyTrips[0];
    }

    final response = await http.post(
      Uri.http(Utils.authority, '/trip'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ${Utils.token}'},
      body: json.encode(
        {
          'name': name,
          'description': description,
          'departureId': departureId,
          'numOfTourists': numOfTourists,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'duration': duration,
          'remarks': remarks,
          'locations': locationIds, // automatically encodes list of strings
        },
      ),
    );
    if (response.statusCode == 200) {
      final body =
          json.decode(const Utf8Decoder().convert(response.body.codeUnits));
      final trip = await fromJsonBody(body);
      _tripPool.add(trip);
      return trip;
    } else {
      print(response.body);
      print(response.body);
      throw 'error in createTrip(). Response was: ${response.body}';
    }
  }

  /// This method returns a trip of a specific ID.
  Future<Trip> fetchTripById(String id) async {
    if (testMode) {
      // FIXME
      return DummyData.dummyTrips[0];
    }

    if (!_tripPool.any((trip) => trip.id == id)) {
      final response = await http.get(
        Uri.http(Utils.authority, '/trip/$id'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer ${Utils.token}'},
      );
      if (response.statusCode == 200) {
        final body =
            json.decode(const Utf8Decoder().convert(response.body.codeUnits));
        final trip = await fromJsonBody(body).catchError((err) => throw err);
        _tripPool.add(trip);
        return trip;
      } else {
        print(response.body);
        throw 'error in fetchTripById Response was: ${response.body}';
      }
    } else {
      return _tripPool.firstWhere((trip) => trip.id == id);
    }
  }

  /// This method utilizes API D1-5. See Apifox for more info.
  /// 0) trigger updateList() according to type
  /// 1) check if current list is emtpy
  /// 2) if not, return current list
  /// 3) else, wait for updateList(), and then return
  /// 4) when updateList() is finished, AND the list is updated, notifyListeners()
  Future<List<Trip>> fetchTripByType({
    bool isFavorite = false,
    bool finished = false,
    bool ongoing = false,
    bool future = false,
    bool recommended = false,
  }) async {
    if (testMode) {
      // FIXME
      return DummyData.dummyTrips;
    }

    try {
      if (isFavorite) {
        if (_favoriteTrips.isEmpty) {
          await updateList(isFavorite: true);
        } else {
          updateList(isFavorite: true);
        }
        return _favoriteTrips;
      }
      if (finished) {
        if (_finishedTrips.isEmpty) {
          await updateList(finished: true);
        } else {
          updateList(finished: true);
        }
        return _finishedTrips;
      }
      if (ongoing) {
        if (_ongoingTrips.isEmpty) {
          await updateList(ongoing: true);
        } else {
          updateList(ongoing: true);
        }
        return _ongoingTrips;
      }
      if (future) {
        if (_futureTrips.isEmpty) {
          await updateList(future: true);
        } else {
          updateList(future: true);
        }
        return _futureTrips;
      }
      if (recommended) {
        if (_recommendedTrips.isEmpty) {
          await updateList(recommended: true);
        } else {
          updateList(recommended: true);
        }
        return _recommendedTrips;
      }
    } catch (_) {
      rethrow;
    }
    throw 'error in fetchTripByType(). Reason unknown.';
  }

  Future<void> updateList({
    bool isFavorite = false,
    bool finished = false,
    bool ongoing = false,
    bool future = false,
    bool recommended = false,
  }) async {
    bool updated = false;
    final response = await http.get(
      Uri.http(Utils.authority, '/trip', {
        if (isFavorite) 'isFavorite': 1,
        if (finished) 'finished': 1,
        if (ongoing) 'ongoing': 1,
        if (future) 'future': 1,
        if (recommended) 'recommended': 1,
      }),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ${Utils.token}'},
    );
    if (response.statusCode == 200) {
      late final List<Trip> resultList;
      if (isFavorite) {
        resultList = _favoriteTrips;
      } else if (finished) {
        resultList = _finishedTrips;
      } else if (ongoing) {
        resultList = _ongoingTrips;
      } else if (future) {
        resultList = _futureTrips;
      } else if (recommended) {
        resultList = _recommendedTrips;
      }
      final body =
          json.decode(const Utf8Decoder().convert(response.body.codeUnits));
      // add new trips to result list if they aren't there
      for (var jsonTrip in body) {
        late final Trip trip;
        if (!_tripPool.any((t) => t.id == jsonTrip['id'])) {
          // add to pool first
          trip = await fromJsonBody(jsonTrip);
          _tripPool.add(trip);
          resultList.add(trip);
          updated = true;
        } else {
          trip = _tripPool.firstWhere((t) => t.id == jsonTrip['id']);
          if (!resultList.any((t) => t.id == jsonTrip['id'])) {
            resultList.add(trip);
            updated = true;
          }
        }
      }
      // remove deprecated trips in result list
      for (Trip trip in resultList) {
        bool isDeprecated = true;
        for (var jsonTrip in body) {
          if (jsonTrip['id'] == trip.id) {
            isDeprecated = false;
          }
        }
        if (isDeprecated) {
          resultList.remove(trip);
          updated = true;
        }
      }
      if (updated) notifyListeners();
    } else {
      print(response.body);
      throw 'error in updateList(). Response was: ${response.body}';
    }
  }

  Future<Trip> fromJsonBody(dynamic body) async {
    final List<Activity> activities = [];
    for (var act in (body['activities'] as List<dynamic>)) {
      final location = await locations
          .fetchLocationById(act['id'])
          .catchError((e) => throw e);
      // Note that ChangeNotifier serves the purpose of signaling the UI
      // to rebuild when some values changed, but not signaling some objects
      // to refresh in memory when some other object changed. Therefore, you
      // cannot and should not initialize Activity with a ProxyProvider here,
      // but do so later when building a UI widget for an Activity.
      activities.add(Activity(
        location: location,
        locationId: act['id'],
        startTime: DateTime.parse(act['startTime']),
        endTime: DateTime.parse(act['endTime']),
        cost: act['cost'],
        type: LocationTypeExtension.fromString(act['type']),
        name: act['name'],
        remarks: act['remarks'],
        duration: act['duration'],
      ));
    }
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

/// How does the "local database" of this app work?
///
/// I. Initialization
/// 1. On initialization, fetch tripIds, then trips according their ids.
/// 2. On instantiating trips, fetch activities according to their ids.
/// 3. On instantiating activities, fetch locations according to their ids.
/// 4. On instantiating locations, fetch destinations according to their ids.
/// Also, destination fetching can wait, more important are the first 3 steps.
/// 
/// TODO: Write APIs to implement these functionalities.
///
/// II. Memory Management
/// Serialize unused objects into json files, store them on the storage, and
/// mark their locations. When an object is needed, load it from the json files.
/// The logic can be implemented using "get_storage", which helps to store
/// simple data on the disk. If there are too much data, use "path_provider"
/// instead, because it helps to navigate the file system more easily, and load
/// data more efficiently. ("get_storage" has to search for the key of the data
/// so it will become inefficient if there are too many entries.)
///
/// Write logic in providers to decide when to write and load objects to memory,
/// and return desired value to the widget, whether it's from the server, disk,
/// or memory.
///
/// To serialize objects into jsons, use "json_serializable". It may be easier
/// if the object structure is the same as the response body.
///
/// The json files can also be periodically trimmed to save space, however, this
/// is more of a user's or the OS's job than ours. The same does not go with
/// larger data though, like images, videos, etc. But, thankfully, we won't
/// interact much with those in this trip planning app. :-)
///
/// III. Other Data
/// 1. Secured data like tokens should be stored using "flutter_secure_storage".
/// 2. Simple key-values like prefrences can be stored using "get_storage" or
/// "shared_preferences".
/// 3. Downloaded files like images can be managed via "flutter_cache_manager".

