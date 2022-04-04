from DestinationService.models import DestinationModel, LocationModel
from TripService.models import TripModel
import json
from datetime import date, time, datetime, timedelta
from rest_framework import serializers

from UserAuth.models import UserModel
from Utils import enums


class TripSerializer(serializers.ModelSerializer):
    # 定位用户模型
    username = serializers.CharField(write_only=True)
    # 定位目的地模型
    departureId = serializers.IntegerField(write_only=True)

    class Meta:
        model = TripModel
        fields = ['id', 'name', 'username', 'isFavorite', 'isRecommend', 'status',
                  'departureId', 'description', 'startDate', 'endDate',
                  'duration', 'remarks', 'activities', 'img_url']

    def create(self, validated_data):
        dest_obj = DestinationModel.objects.filter(id=validated_data.pop('departureId')).first()
        user_obj = UserModel.objects.filter(username=validated_data.pop('username')).first()

        # acts_json = validated_data.pop('activities')
        #
        # num_of_acts = len(acts_json)  # 测试
        # total_cost = len(acts_json)  # 测试

        trip = TripModel.objects.create(
            creator=user_obj,
            departure=dest_obj,
            **validated_data)
        return trip


class TripSmartSerializer(serializers.ModelSerializer):
    # 定位用户模型
    username = serializers.CharField(write_only=True)
    # 定位目的地模型
    departureId = serializers.IntegerField(write_only=True)

    # 传入的 要生成行程中活动的 地点id
    locationIds = serializers.ListField(child=serializers.IntegerField(), allow_empty=False, write_only=True)

    class Meta:
        model = TripModel
        fields = ['id', 'name', 'username', 'status', 'departureId', 'description', 'startDate', 'endDate',
                  'duration', 'remarks', 'numOfTourists', "locationIds"]

    def create(self, validated_data):
        dest_obj = DestinationModel.objects.filter(id=validated_data.pop('departureId')).first()
        user_obj = UserModel.objects.filter(username=validated_data.pop('username')).first()

        # TODO: 智能生成活动字段
        activities = []

        init_startTime = datetime.combine(validated_data['startDate'], time(9, 0, 0))
        print(init_startTime)

        curr_startTime = init_startTime
        # 理应为int类型数组
        for siteId in validated_data.pop("locationIds"):
            location_obj = LocationModel.objects.filter(id=siteId).first()

            act_dict = {'locationId': siteId,
                        'startTime': curr_startTime.strftime("%Y-%m-%d %H:%M:%S"),
                        'endTime': (curr_startTime +
                                    timedelta(minutes=location_obj.timeCost + 60)).strftime("%Y-%m-%d %H:%M:%S"),
                        "name": location_obj.name,

                        # TODO: type改为由enums.TripActivityType构成的枚举
                        "type": location_obj.type,
                        "duration": location_obj.timeCost + 60,
                        "cost": location_obj.cost,
                        "remarks": "【remarks】"
                        }
            # print(act_dict)
            activities.append(json.dumps(act_dict, ensure_ascii=False))

            curr_startTime = curr_startTime + timedelta(minutes=location_obj.timeCost + 60)

        # print(activities)
        activities_str = activities.__str__()
        # 由于Response返回时会自动进行 json 序列化，所以这里无需再进行序列化
        # activities_str = json.dumps(activities, ensure_ascii=False)

        # print(activities_str)
        trip = TripModel.objects.create(
            creator=user_obj,
            departure=dest_obj,
            activities=activities_str,
            **validated_data)
        return trip
