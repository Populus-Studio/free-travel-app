from enum import Enum
import random


class TripActivityType:
    business = "商圈"
    landmark = "地标"
    attraction = "景点"
    resort = "游乐园"
    internetFamous = "网红地"
    restaurant = "餐饮"
    entertainment = "娱乐场所"
    exhibition = "展览"
    accommodation = "住宿"
    transportation = "交通"
    publicFacility = "公共设施"
    others = "景点"


def get_trip_activity_type(str_type):
    if str_type == "business":
        return TripActivityType.business
    elif str_type == "landmark":
        return TripActivityType.landmark
    elif str_type == "attraction":
        return TripActivityType.attraction
    elif str_type == "resort":
        return TripActivityType.resort
    elif str_type == "internetFamous":
        return TripActivityType.internetFamous
    elif str_type == "restaurant":
        return TripActivityType.restaurant
    elif str_type == "entertainment":
        return TripActivityType.entertainment
    elif str_type == "exhibition":
        return TripActivityType.exhibition
    elif str_type == "accommodation":
        return TripActivityType.accommodation
    elif str_type == "transportation":
        return TripActivityType.transportation
    elif str_type == "publicFacility":
        return TripActivityType.publicFacility
    else:
        return TripActivityType.others


class TransportationType:
    type_name = ["bike", "scooter", "walk", "car", "taxi", "bus", "subway", "ferry", "tram", "cableCar", "other"]
    str_res = ["骑自行车", "骑电动车", "步行", "驾车", "打车", "公交", "地铁", "轮渡", "电车", "索道", "其他"]


def get_transportation_type():
    return random.choices(TransportationType.str_res, weights=[5, 5, 5, 10, 10, 10, 8, 1, 1, 1, 1], k=1)[0]

