import '../providers/location.dart';

/// This class saves some dummy data for testing purposes.
class DummyData {
  static late final dummyLocations = [
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
}
