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

  /// This method posts a locally generated Trip to the server. It could be used
  /// to update a certain field in an existing trip or for testing purposes. It
  /// posts a trip WITH an ID and does NOT expect the API to return a different
  /// ID. Please see and differentiate with [createTrip()].
  Future<void> postTrip(Trip trip) async {
    final body = trip.toJson();
    if (testMode) body.addAll({'status': 0});
    final response = await http.post(Uri.http(Utils.authority, '/trip/'),
        headers: Utils.authHeader..addAll(Utils.jsonHeader),
        body: json.encode(body));
    print(response.body);
    if (response.statusCode == 201) {
      _tripPool.removeWhere((t) => t.id == trip.id);
      _tripPool.add(trip);
      final body =
          json.decode(const Utf8Decoder().convert(response.body.codeUnits));
      print('success! new trip id: ${body['data']['id']}');
      return;
    } else {
      throw 'Error in postTrip(). Response was: ${response.body}';
    }
  }

  /// This method creates an AI-scheduled trip based on a list of locations. It
  /// is different from [postTrip()] which takes a locally generated Trip object
  /// and uploads it the server. [postTrip()] is for updating trip info (e.g.
  /// remarks, descriptions, etc.) and testing purposes. [createTrip()] expects
  /// a server-side generated Trip with an server-side generated ID to be
  /// returned by the API. It is THE method to use to create a new Trip that 1)
  /// does not exist on the server nor locally, and 2) not for testing purposes.
  /// If either 1) or 2) is not met, consider using [postTrip()].
  Future<Trip> createTrip({
    required String name,
    required String description,
    required String departureId,
    required int numOfTourists,
    required DateTime startDate,
    required DateTime endDate,
    required int duration,
    required List<String> locationIds,
    required String remarks,
  }) async {
    // FIXME: A different API should be used here
    final response = await http.post(
      Uri.http(Utils.authority, '/trip/new/'),
      headers: Utils.authHeader..addAll(Utils.jsonHeader),
      body: json.encode(
        {
          'name': name,
          'username': Utils.username,
          'description': description,
          'departureId': departureId,
          'numOfTourists': numOfTourists,
          'startDate': startDate.toIso8601String().substring(0, 10),
          'endDate': endDate.toIso8601String().substring(0, 10),
          'duration': duration,
          'remarks': remarks,
          'locationIds': locationIds, // automatically encodes list of strings
        },
      ),
    );
    if (response.statusCode == 201) {
      final body =
          json.decode(const Utf8Decoder().convert(response.body.codeUnits));
      final trip = await fromJsonBody(body['data']);
      _tripPool.add(trip);
      return trip;
    } else {
      throw 'Error in createTrip(). Response was: ${response.body}';
    }
  }

  /// This method returns a trip of a specific ID. Set 'test: false' to disable
  /// global test mode.
  Future<Trip> fetchTripById(String id, {test = false}) async {
    if (testMode && test) {
      // FIXME
      return Future.delayed(
          const Duration(seconds: 30), () => DummyData.dummyTrips[0]);
    }

    if (!_tripPool.any((trip) => trip.id == id)) {
      final response = await http.get(
        Uri.http(Utils.authority, '/trip/$id'),
        headers: Utils.authHeader,
      );
      if (response.statusCode == 200) {
        final body =
            json.decode(const Utf8Decoder().convert(response.body.codeUnits));
        final trip =
            await fromJsonBody(body['trip']).catchError((err) => throw err);
        _tripPool.removeWhere((t) => t.id == trip.id);
        _tripPool.add(trip);
        return trip;
      } else {
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
    bool recent = false,
    int num = 10,
  }) async {
    // if (testMode) {
    //   // FIXME
    //   return [_tripPool[0], _tripPool[0], _tripPool[0]];
    //   return Future.delayed(
    //       const Duration(seconds: 1), () => DummyData.dummyTrips);
    // }

    try {
      if (isFavorite) {
        if (_favoriteTrips.isEmpty) {
          await updateList(num: num, isFavorite: true);
        } else {
          updateList(num: num, isFavorite: true);
        }
        return _favoriteTrips;
      }
      if (finished) {
        if (_finishedTrips.isEmpty) {
          await updateList(num: num, finished: true);
        } else {
          updateList(num: num, finished: true);
        }
        return _finishedTrips;
      }
      if (ongoing) {
        if (_ongoingTrips.isEmpty) {
          await updateList(num: num, ongoing: true);
        } else {
          updateList(num: num, ongoing: true);
        }
        return _ongoingTrips;
      }
      if (future) {
        if (_futureTrips.isEmpty) {
          await updateList(num: num, future: true);
        } else {
          updateList(num: num, future: true);
        }
        return _futureTrips;
      }
      // return all trips by default
      return await updateList(num: num);
      // if (recommended) {
      //   if (_recommendedTrips.isEmpty) {
      //     await updateList(num: num, recommended: true);
      //   } else {
      //     updateList(num: num, recommended: true);
      //   }
      //   return _recommendedTrips;
      // }
    } catch (_, stacktrace) {
      print(_);
      print(stacktrace);
      rethrow;
    }
    throw 'error in fetchTripByType(). Reason unknown.';
  }

  Future<List<Trip>> updateList({
    bool isFavorite = false,
    bool finished = false,
    bool ongoing = false,
    bool future = false,
    bool recommended = false,
    String keywords = '',
    int num = 10,
  }) async {
    bool updated = false;
    final List<Trip> ret = [];
    // TODO: Use paging
    final response = await http.get(
      Uri.http(
          Utils.authority,
          '/trip/me/',
          {
            'isFavorite': isFavorite ? 1 : 0,
            'finished': finished ? 1 : 0,
            'ongoing': ongoing ? 1 : 0,
            'future': future ? 1 : 0,
            'recommended': recommended ? 1 : 0,
            'keywords': keywords,
            'page': 1,
            'size': num,
          }.map(
            (key, value) => MapEntry(key, value.toString()),
          )),
      headers: Utils.authHeader,
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
      } else {
        resultList = _tripPool;
      }
      final body =
          json.decode(const Utf8Decoder().convert(response.body.codeUnits));
      final tripList = body['_embedded']['tripDtoList'];
      // add new trips to result list if they aren't there
      // FIXME: See below. This adding to the pool logic does not work either.
      for (var jsonTrip in tripList) {
        // if (!_tripPool.any((t) => t.id == (jsonTrip['id'] as int).toString())) {
        //   print('id: ${(jsonTrip['id'] as int).toString()}');
        //   late final Trip trip;
        //   trip = await fromJsonBody(jsonTrip);
        //   _tripPool.add(trip);
        //   print('added! _tripPool.length: ${_tripPool.length}');
        //   updated = true;
        // }
        // if (!_tripPool.any((t) => t.id == jsonTrip['id'])) {
        //   // add to pool first
        //   trip = await fromJsonBody(jsonTrip);
        //   _tripPool.add(trip);
        //   resultList.add(trip);
        //   updated = true;
        // } else {
        //   trip = _tripPool.firstWhere((t) => t.id == jsonTrip['id']);
        //   if (!resultList.any((t) => t.id == jsonTrip['id'])) {
        //     resultList.add(trip);
        //     updated = true;
        //   }
        // }
        ret.add(await fromJsonBody(jsonTrip));
      }
      // FIXME: remove deprecated trips in result list
      // TODO: After implementing this feature, remove clearALLCache() from the
      // top of this method.
      // ERROR: Concurrent iteration and modification is not okay!!
      // SOLUTION: store new trips in a temp list, and then remove deprecated
      // from old list before adding all trips from temp list to old list, which
      // is resultList.
      // for (Trip trip in resultList) {
      //   bool isDeprecated = true;
      //   for (var jsonTrip in tripList) {
      //     if (jsonTrip['id'] == trip.id) {
      //       isDeprecated = false;
      //     }
      //   }
      //   if (isDeprecated) {
      //     resultList.remove(trip);
      //     updated = true;
      //   }
      // }
      if (updated) notifyListeners();
    } else {
      print(response.body);
      throw 'error in updateList(). Response was: ${response.body}';
    }
    return ret;
  }

  /// This is a temp solution to a back-end bug.
  String _fix(dynamic qqc) {
    if (qqc is String && qqc.length > 1 && qqc[1] == "'") {
      qqc = qqc.replaceAll(RegExp(r"'"), '');
    } else if (qqc is num) {
      qqc = '$qqc';
    }
    return qqc;
  }

  Future<Trip> fromJsonBody(dynamic body) async {
    final List<Activity> activities = [];
    int totalCost = 0;
    // See toJson() in Trip class for explanation for this anomaly.
    // TODO: Remove _fix
    for (var act in (json.decode(_fix(body['activities'])) as List<dynamic>)) {
      totalCost += (act['cost'] as num).toInt();
      final location = act['type'] != '交通'
          ? await locations
              .fetchLocationById(_fix(act['locationId']))
              .catchError((e) => throw e)
          : null;
      if (location != null) await location.loadImage();
      // Note that ChangeNotifier serves the purpose of signaling the UI
      // to rebuild when some values changed, but not signaling some objects
      // to refresh in memory when some other object changed. Therefore, you
      // cannot and should not initialize Activity with a ProxyProvider here,
      // but do so later when building a UI widget for an Activity.
      activities.add(Activity(
        location: location,
        locationId: _fix(act['locationId']),
        startTime: DateTime.parse(act['startTime']),
        endTime: DateTime.parse(act['endTime']),
        cost: (act['cost'] as num).toDouble(),
        type: LocationTypeExtension.fromString(act['type']),
        name: act['name'],
        remarks: act['remarks'],
        duration: act['duration'],
      ));
    }
    final Trip trip = Trip(
      id: body['id'].toString(),
      name: body['name'],
      description: body['description'],
      departureId:
          body['departureId'] ?? 0, // FIXME: this is due to a back-end bug
      numOfTourists: body['numOfTourists'] ?? 1,
      startDate: DateTime.parse(body['startDate']),
      endDate: DateTime.parse(body['endDate']),
      duration: body['duration'],
      activities: activities,
      totalCost: totalCost,
      remarks: body['remarks'],
      isFavorite: body['isFavorite'],
      username: body['username'] ?? !body['isRecommend']
          ? Utils.username
          : '', // FIXME: also back-end bug
    );
    return trip;
  }

  void clearAllCache() {
    _tripPool.clear();
    _favoriteTrips.clear();
    _finishedTrips.clear();
    _futureTrips.clear();
    _ongoingTrips.clear();
    _recommendedTrips.clear();
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
