import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

enum LocationType {
  business, // 商圈
  landmark, // 地标
  attraction, // 景点
  resort, // 游乐场
  internetFamous, // 网红打卡点
  restaurant, // 餐馆
  entertainment, // 娱乐场所，KTV等
  exhibition, // 展览
  accommodation, // 住宿
  transportation, // 交通
  publicFacility, // 公共设施
  others, // 其它
}

class Location with ChangeNotifier {
  final String id;
  final String name;
  final List<String> label;
  final LocationType type;
  final String destinationId;
  final String address;
  final String description;
  final double cost; // CNY
  final double timeCost; // minutes
  final int rate; // range: [0, 5]
  final int heat; // range: [0, 1000]
  final String opentime;
  final String imageUrl;

  PaletteColor? palette;
  Image? img;
  bool isFavorite;

  Future loadImage() async {
    // lazy load image, always call this before accessing images and palettes!
    if (img == null || palette == null) {
      img = Image.network(imageUrl);
      final generator = await PaletteGenerator.fromImageProvider(
        img!.image,
        size: const Size(200, 200),
      );
      palette = generator.darkMutedColor ?? PaletteColor(Colors.purple, 2);
    }
  }

  Location({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    required this.destinationId,
    required this.address,
    required this.description,
    required this.cost,
    required this.timeCost,
    required this.rate,
    required this.heat,
    required this.opentime,
    required this.imageUrl,
    required this.isFavorite,
  }) {
    loadImage(); // This allows automatic lazy loading images.
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    // TODO: Update to server
  }
}

extension LocationTypeExtension on LocationType {
  String toChineseString() {
    switch (this) {
      case LocationType.business:
        return "商圈";
      case LocationType.accommodation:
        return "住宿";
      case LocationType.attraction:
        return "景点";
      case LocationType.landmark:
        return "地标性建筑";
      case LocationType.resort:
        return "游乐园";
      case LocationType.entertainment:
        return "娱乐场所";
      case LocationType.exhibition:
        return "展览";
      case LocationType.internetFamous:
        return "网红打卡点";
      case LocationType.restaurant:
        return "餐饮";
      case LocationType.others:
        return "其它";
      case LocationType.transportation:
        return "交通";
      case LocationType.publicFacility:
        return "公共设施";
      default:
        return "未知";
    }
  }

// TODO: Return LocationType based on string received from server
  static LocationType fromString(String string) {
    switch (string) {
      default:
        return LocationType.attraction;
    }
  }
}
