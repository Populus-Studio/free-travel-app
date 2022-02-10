import 'package:cacatripplanner/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './location.dart';

const url = 'http://152.136.233.65:80';

// Always add 'listen: false' when accessing this provider because it changes
// every time the pool updates (which happens very frequently), and listeners
// should never need to know about the memory management under the hood.
class Locations with ChangeNotifier {
  bool hasRanded = false; // FIXME: This is for testing purposes only.
  final List<Location> _locationPool = [];

  final List<String> _recommendedLocationIds = [];

  final List<String> _favoriteLocationIds = [];

  List<Location> _recommendedLocationList = [];

  /// This method returns a location and save it to _locationPool if it exists.
  Future<Location?> fetchLocationById(String id) async {
    if (!_locationPool.any((loc) => id == loc.id)) {
      // fetch location info from server
      final response = await http.get(
        Uri.parse(url + '/site/' + id),
        headers: {'Authorization': 'Bearer ${Utils.token}'},
      );
      // Don't user timeout if you're not ready to handle the error!!!
      // ).timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        var body = json.decode(
            const Utf8Decoder().convert(response.body.codeUnits))['site'];
        Location location = Location(
          id: body['id'].toString(),
          name: body['name'],
          label: body['label'].split(',').toList(),
          type: LocationTypeExtension.fromString(body['type']),
          destinationId: body['destination_id'] ?? (-1).toString(),
          address: body['address'],
          description: body['description'],
          cost: body['cost'].toDouble(),
          timeCost: body['timeCost'].toDouble(),
          rate: body['rate'].toInt(),
          heat: body['heat'].toInt(),
          opentime: body['opentime'],
          imageUrl: body['img_url'],
          isFavorite: false,
        );
        _locationPool.add(location);
        return location;
      } else {
        print("Error in fetching location $id:");
        print(response.body);
        return null;
      }
    } else {
      return _locationPool.firstWhere((loc) => loc.id == id);
    }
  }

  // TODO: This function dynamically allocates/manages RAM!!
  void updateLocationPool() {
    notifyListeners();
  }

  void updateRecommendedLocationIds() {
    /// for now, every time the recommended locations are fetched, we add a new
    /// one into it.
    // _recommendedLocationIds
    //     .add('${int.parse(_recommendedLocationIds.last) + 1}');
    if (true) {
      _recommendedLocationIds.clear();
      for (int i = 0; i < 10; i++) {
        _recommendedLocationIds.add(Utils.rng.nextInt(7000).toString());
      }
      hasRanded = true;
    } else {
      // _recommendedLocationIds
      //     .add('${int.parse(_recommendedLocationIds.last) + 1}');
    }
    // This is a small hack to prevent calling notifyListeners() (and thus
    // setState(), when the widget is building). For more info, see: https://stackoverflow.com/questions/59378267/flutter-provider-setstate-or-markneedsbuild-called-during-build
    Future.delayed(const Duration(milliseconds: 0), () => notifyListeners());
  }

  /// Load Image Type: 1
  List<Location> get favoriteLocations {
    // TODO: update _favoriteLocations list and then return.
    updateLocationPool();
    notifyListeners();
    // they are not already there
    return _locationPool
        .where((loc) => _favoriteLocationIds.any((id) => id == loc.id))
        .toList();
  }

  /// Async getter. Load Image Type: 2
  Future<List<Location>> get recommendedLocations async {
    // update _recommendedLocations list
    updateRecommendedLocationIds();
    // add location to pool if it's not there
    for (var id in _recommendedLocationIds) {
      await fetchLocationById(id);
    }
    updateLocationPool();
    _recommendedLocationList = _locationPool
        .where((loc) => _recommendedLocationIds.any((id) => id == loc.id))
        .toList();
    notifyListeners();
    return _recommendedLocationList;
  }

  /// Load images of [num] locations of type [type].
  /// This turns out to be a redundant function after careful design.
  Future<void> loadImages({int num = 10, int type = 0}) async {
    // Since this method is called everytime user enters select_screen from
    // main_screen, we reset hasRanded here to fetch another 10 locations.
    hasRanded = false;
    final List<Location> locations;
    switch (type) {
      case 0:
        // updateLocationPool(); // this function dynamically manages RAM!
        locations = _locationPool;
        break;
      case 1:
        // updateFavoriteLocations();
        locations = favoriteLocations;
        break;
      case 2:
        locations = await recommendedLocations;
        break;
      default:
        return;
    }
    for (int i = 0; i < num; i++) {
      if (i < locations.length) {
        await locations[i].loadImage();
      } else {
        break;
      }
    }
    notifyListeners();
  }
}
