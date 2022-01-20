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
  final List<Location> _locationPool = [
    Location(
      id: '1',
      name: '三里屯',
      label: ['常去'],
      type: LocationType.business,
      destinationId: '010',
      address: '北京市朝阳区三里屯路',
      description: '北京著名商圈',
      cost: 200,
      timeCost: 120,
      rate: 5,
      heat: 830,
      opentime: '周一至周日',
      imageUrl:
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fccm.maotuying.com%2Fdiscovery%2Fproduction%2F1539925431_RackMultipart20181019-1-10jl425.jpg&refer=http%3A%2F%2Fccm.maotuying.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1640521215&t=9ca9bb5ef58fbfca4fbc8451a4268f51',
      isFavorite: true,
    ),
    Location(
      id: '2',
      name: '广州塔',
      label: ['好玩'],
      type: LocationType.landmark,
      destinationId: '020',
      address: '广东省广州市海珠区阅江西路',
      description: '广州市著名地标建筑',
      cost: 300,
      timeCost: 180,
      rate: 5,
      heat: 700,
      opentime: '周一至周日',
      imageUrl:
          'http://img0.baidu.com/it/u=2702259571,3049677831&fm=253&app=138&f=JPEG?w=818&h=500',
      isFavorite: true,
    ),
    Location(
      id: '3',
      name: '故宫博物院',
      label: ['好大'],
      type: LocationType.attraction,
      destinationId: '010',
      address: '北京市东城区景山前街4号',
      description: '中国最大的古代文化艺术博物馆',
      cost: 50,
      timeCost: 360,
      rate: 5,
      heat: 1000,
      opentime: '周一至周日',
      imageUrl:
          'http://img1.baidu.com/it/u=970304172,3399065154&fm=253&app=138&f=JPEG?w=236&h=158',
      isFavorite: true,
    ),
    Location(
      id: '4',
      name: '长沙文和友',
      label: ['人多'],
      type: LocationType.internetFamous,
      destinationId: '0731',
      address: '湖南省长沙市天心区长沙五一商圈湘江中路',
      description: '长沙著名网红打卡地，文和友龙虾餐厅',
      cost: 100,
      timeCost: 120,
      rate: 3,
      heat: 900,
      opentime: '周一至周日',
      imageUrl:
          'http://img1.baidu.com/it/u=2515363814,70635887&fm=253&app=138&f=JPEG?w=500&h=333',
      isFavorite: true,
    ),
  ];

  final List<String> _recommendedLocationIds = [
    '1',
    '2',
    '3',
    '4',
  ];

  final List<String> _favoriteLocationIds = [
    '1',
    '2',
    '3',
    '4',
  ];

  List<Location> recommendedLocationList = [];

  // TODO: This function dynamically allocates/manages RAM!!
  void updateLocationPool() {}

  void updateRecommendedLocations() {
    /// for now, every time the recommended locations are fetched, we add a new
    /// one into it.
    // _recommendedLocationIds
    //     .add('${int.parse(_recommendedLocationIds.last) + 1}');
    if (!hasRanded) {
      _recommendedLocationIds.clear();
      for (int i = 0; i < 10; i++) {
        _recommendedLocationIds.add(Utils.rng.nextInt(7000).toString());
      }
      hasRanded = true;
    } else {
      // _recommendedLocationIds
      //     .add('${int.parse(_recommendedLocationIds.last) + 1}');
    }
  }

  List<Location> get favoriteLocations {
    // Load Image Type: 1
    // TODO: update _favoriteLocations list and then return.
    updateLocationPool();
    // they are not already there
    return _locationPool
        .where((loc) => _favoriteLocationIds.any((id) => id == loc.id))
        .toList();
  }

  Future<List<Location>> get recommendedLocations async {
    // Load Image Type: 2
    // update _recommendedLocations list
    updateRecommendedLocations();
    // add location to pool if it's not there
    for (var id in _recommendedLocationIds) {
      // _recommendedLocationIds.forEach((id) async {
      if (!_locationPool.any((loc) => id == loc.id)) {
        // fetch location info from server
        var response = await http
            .get(
              Uri.parse(url + '/site/' + id),
              headers: {'Authorization': 'Bearer ${Utils.token}'},
            )
            .timeout(const Duration(seconds: 1))
            .catchError((error) {
              print("Error in fetching location $id");
            });

        if (response.statusCode == 200) {
          var body = json.decode(
              const Utf8Decoder().convert(response.body.codeUnits))['site'];
          _locationPool.add(Location(
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
          ));
        } else {
          print("Error in fetching location $id:");
          print(response.body);
        }
      }
      // });
    }
    updateLocationPool();
    print(_recommendedLocationIds);
    print(_locationPool.length);
    recommendedLocationList = _locationPool
        .where((loc) => _recommendedLocationIds.any((id) => id == loc.id))
        .toList();
    return recommendedLocationList;
  }

  /// Load images of [num] locations of type [type].
  Future loadImages({int num = 10, int type = 0}) async {
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
  }
}
