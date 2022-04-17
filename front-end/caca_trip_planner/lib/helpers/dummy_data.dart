import 'package:cacatripplanner/providers/activity.dart';
import 'package:cacatripplanner/providers/trip.dart';

import '../providers/location.dart';

/// This class saves some dummy data for testing purposes.
class DummyData {
  static late final List<Location> dummyLocations = [
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
          'https://youimg1.c-ctrip.com/target/0106o120008632x65D55A_D_521_391.jpg',
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

  static late final List<String> dummyRecommendedLocationIds = [
    '1',
    '2',
    '3',
    '4',
  ];

  static late final List<String> dummyFavoriteLocationIds = [
    '1',
    '2',
    '3',
    '4',
  ];

  /// The location ids are real, but others are kinda dumb.
  static late final List<Activity> dummyActivities = [
    Activity(
      location: dummyLocations[1],
      locationId: '49',
      startTime: DateTime.parse('2022-02-11T08:00:00.000000'),
      endTime: DateTime.parse('2022-02-11T10:30:00.000000'),
      cost: 50,
      type: LocationType.attraction,
      name: '什刹海',
      remarks: '早上去人少',
      duration: 150,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-11T10:30:00.000000'),
      endTime: DateTime.parse('2022-02-11T11:00:00.000000'),
      cost: 40,
      type: LocationType.transportation,
      name: '打车',
      remarks: '',
      duration: 30,
    ),
    Activity(
      location: dummyLocations[3],
      locationId: '65',
      startTime: DateTime.parse('2022-02-11T11:00:00.000000'),
      endTime: DateTime.parse('2022-02-11T11:30:00.000000'),
      cost: 0,
      type: LocationType.landmark,
      name: '天安门广场',
      remarks: '必去，在外围逛逛就好',
      duration: 30,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-11T11:30:00.000000'),
      endTime: DateTime.parse('2022-02-11T11:36:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '骑自行车',
      remarks: '',
      duration: 6,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '104',
      startTime: DateTime.parse('2022-02-11T11:40:00.000000'),
      endTime: DateTime.parse('2022-02-11T12:40:00.000000'),
      cost: 177,
      type: LocationType.restaurant,
      name: '四季民福（故宫店）',
      remarks: '因为暂时没有这个Location，用北京大学代替。',
      duration: 120,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-11T12:40:00.000000'),
      endTime: DateTime.parse('2022-02-11T13:00:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '骑电动车',
      remarks: '',
      duration: 11,
    ),
    Activity(
      location: dummyLocations[3],
      locationId: '36',
      startTime: DateTime.parse('2022-02-11T13:00:00.000000'),
      endTime: DateTime.parse('2022-02-11T15:00:00.000000'),
      cost: 0,
      type: LocationType.internetFamous,
      name: '北海公园',
      remarks: '可以划划船',
      duration: 120,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-11T15:00:00.000000'),
      endTime: DateTime.parse('2022-02-11T16:00:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '公交',
      remarks: '4路车，大西洋新城南门方向，9个站。',
      duration: 45,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '6',
      startTime: DateTime.parse('2022-02-11T16:00:00.000000'),
      endTime: DateTime.parse('2022-02-11T19:00:00.000000'),
      cost: 200,
      type: LocationType.attraction,
      name: '三里屯',
      remarks: '',
      duration: 180,
    ),
    Activity(
      location: dummyLocations[2],
      locationId: '49',
      startTime: DateTime.parse('2022-02-12T08:00:00.000000'),
      endTime: DateTime.parse('2022-02-12T10:30:00.000000'),
      cost: 50,
      type: LocationType.attraction,
      name: '什刹海',
      remarks: '早上去人少',
      duration: 150,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-12T10:30:00.000000'),
      endTime: DateTime.parse('2022-02-12T11:00:00.000000'),
      cost: 40,
      type: LocationType.transportation,
      name: '步行',
      remarks: '',
      duration: 30,
    ),
    Activity(
      location: dummyLocations[3],
      locationId: '65',
      startTime: DateTime.parse('2022-02-12T11:00:00.000000'),
      endTime: DateTime.parse('2022-02-12T11:30:00.000000'),
      cost: 0,
      type: LocationType.landmark,
      name: '天安门广场',
      remarks: '',
      duration: 30,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-12T11:30:00.000000'),
      endTime: DateTime.parse('2022-02-12T11:36:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '地铁',
      remarks: '',
      duration: 6,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '104',
      startTime: DateTime.parse('2022-02-12T11:40:00.000000'),
      endTime: DateTime.parse('2022-02-12T12:40:00.000000'),
      cost: 177,
      type: LocationType.restaurant,
      name: '四季民福（故宫店）',
      remarks: '',
      duration: 120,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-12T12:40:00.000000'),
      endTime: DateTime.parse('2022-02-12T13:00:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '电车',
      remarks: '',
      duration: 11,
    ),
    Activity(
      location: dummyLocations[3],
      locationId: '36',
      startTime: DateTime.parse('2022-02-12T13:00:00.000000'),
      endTime: DateTime.parse('2022-02-12T15:00:00.000000'),
      cost: 0,
      type: LocationType.attraction,
      name: '北海公园',
      remarks: '可以划划船',
      duration: 120,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-12T15:00:00.000000'),
      endTime: DateTime.parse('2022-02-12T16:00:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '电车',
      remarks: '4路车，大西洋新城南门方向，9个站。',
      duration: 45,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '6',
      startTime: DateTime.parse('2022-02-12T16:00:00.000000'),
      endTime: DateTime.parse('2022-02-12T19:00:00.000000'),
      cost: 200,
      type: LocationType.entertainment,
      name: '三里屯',
      remarks: '必去星巴克、优衣库。在这里顺便吃晚饭。',
      duration: 180,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-12T10:30:00.000000'),
      endTime: DateTime.parse('2022-02-12T11:00:00.000000'),
      cost: 40,
      type: LocationType.transportation,
      name: '轮渡',
      remarks: '',
      duration: 30,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '104',
      startTime: DateTime.parse('2022-02-13T11:40:00.000000'),
      endTime: DateTime.parse('2022-02-13T12:40:00.000000'),
      cost: 177,
      type: LocationType.restaurant,
      name: '四季民福（故宫店）',
      remarks: '',
      duration: 120,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-13T12:40:00.000000'),
      endTime: DateTime.parse('2022-02-13T13:00:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '电车',
      remarks: '',
      duration: 11,
    ),
    Activity(
      location: dummyLocations[3],
      locationId: '36',
      startTime: DateTime.parse('2022-02-13T13:00:00.000000'),
      endTime: DateTime.parse('2022-02-13T15:00:00.000000'),
      cost: 0,
      type: LocationType.attraction,
      name: '北海公园',
      remarks: '可以划划船',
      duration: 120,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-13T15:00:00.000000'),
      endTime: DateTime.parse('2022-02-13T16:00:00.000000'),
      cost: 2,
      type: LocationType.transportation,
      name: '电车',
      remarks: '4路车，大西洋新城南门方向，9个站。',
      duration: 45,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '6',
      startTime: DateTime.parse('2022-02-13T16:00:00.000000'),
      endTime: DateTime.parse('2022-02-13T19:00:00.000000'),
      cost: 200,
      type: LocationType.entertainment,
      name: '三里屯',
      remarks: '必去星巴克、优衣库。在这里顺便吃晚饭。',
      duration: 180,
    ),
    Activity(
      locationId: '-1',
      startTime: DateTime.parse('2022-02-13T10:30:00.000000'),
      endTime: DateTime.parse('2022-02-13T11:00:00.000000'),
      cost: 40,
      type: LocationType.transportation,
      name: '索道',
      remarks: '',
      duration: 30,
    ),
    Activity(
      location: dummyLocations[1],
      locationId: '6',
      startTime: DateTime.parse('2022-02-13T16:00:00.000000'),
      endTime: DateTime.parse('2022-02-13T19:00:00.000000'),
      cost: 200,
      type: LocationType.entertainment,
      name: '三里屯',
      remarks: '必去星巴克、优衣库。在这里顺便吃晚饭。',
      duration: 180,
    ),
  ];

  static late final List<Trip> dummyTrips = [
    Trip(
      id: '7',
      name: '北京周末之行',
      description: '大学生休闲游',
      departureId: 2,
      numOfTourists: 6,
      startDate: DateTime.parse('2022-02-11T08:00:00.000000'),
      endDate: DateTime.parse('2022-02-13T00:00:00.000000'),
      duration: 3,
      activities: dummyActivities,
      totalCost: 500,
      remarks: '该行程适合秋季出游，走访北京景点旅游景点！该行程两天内容是一样的。',
      isFavorite: true,
      username: 'huyang',
    ),
  ];
}
