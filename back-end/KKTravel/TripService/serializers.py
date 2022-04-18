from DestinationService.models import DestinationModel, LocationModel
from TripService.models import TripModel
import json
import random
from datetime import date, time, datetime, timedelta
from rest_framework import serializers

from UserAuth.models import UserModel
from Utils import enums, geocode




class TripSerializer(serializers.ModelSerializer):
    # 定位用户模型
    username = serializers.CharField(write_only=True)
    # 定位目的地模型
    departureId = serializers.IntegerField(write_only=True)

    class Meta:
        model = TripModel
        fields = ['id', 'name', 'username', 'isFavorite', 'isRecommend',
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
        fields = ['id', 'name', 'username','departureId', 'description', 'startDate',
                  'duration', 'remarks', 'numOfTourists', "locationIds"]

    def create(self, validated_data):
        dest_obj = DestinationModel.objects.filter(id=validated_data.pop('departureId')).first()
        user_obj = UserModel.objects.filter(username=validated_data.pop('username')).first()

        activities = []
        init_startTime = datetime.combine(validated_data['startDate'], time(9, 0, 0))
        trip_days = 0
        print(init_startTime)

        curr_startTime = init_startTime
        # 理应为int类型数组
        locations = validated_data.pop("locationIds")
        for i in range(len(locations)):
            curr_id = locations[i]
            location_obj = LocationModel.objects.filter(id=curr_id).first()
            next_location_obj = None
            if i + 1 < len(locations):
                next_location_obj = LocationModel.objects.filter(id=locations[i + 1]).first()

            # TEMP: rand duration
            rand_duration = random.randrange(60, 240, 30)
            end_time = curr_startTime + timedelta(minutes=rand_duration)
            print("start:" + curr_startTime.isoformat())
            print("end" + end_time.isoformat())

            # 增加当前场景的活动
            act_dict = {'locationId': str(curr_id),
                        'geoCode': geocode.get_geocode(location_obj.address),
                        'startTime': curr_startTime.isoformat(),
                        'endTime': end_time.isoformat(),
                        "name": location_obj.name,
                        # type改为由enums.TripActivityType构成的枚举
                        "type": enums.get_trip_activity_type(location_obj.type),
                        "duration": rand_duration,
                        "cost": random.randrange(0, 200, 10),
                        # 活动中的remarks留空
                        "remarks": ""
                        }
            # print(act_dict)
            activities.append(act_dict)

            rand_trans_duration = random.randrange(10, 60, 5)
            rand_trans_cost = random.randint(0, 25)
            if end_time.hour > 19:
                # 时间过晚，后续活动添加到下一天
                trip_days += 1
                if next_location_obj is not None:
                    curr_startTime = init_startTime + timedelta(days=trip_days)
                continue
            else:
                # 添加交通活动
                trans_endTime = end_time + timedelta(minutes=rand_trans_duration)

            # 如果是最后一个地点，不用再添加交通活动
            if next_location_obj is None:
                continue
            # 增加两个场景间交通的活动
            trans_act_dict = {'locationId': "-1",
                              'geoCode': "-1",
                              'startTime': end_time.isoformat(),
                              'endTime': trans_endTime.isoformat(),
                              # 交通活动的name代表其交通方式
                              "name": enums.get_transportation_type(),
                              "type": enums.TripActivityType.transportation,
                              "duration": rand_trans_duration,
                              "cost": rand_trans_cost,
                              # 交通活动的remarks标记其起止位置
                              "remarks": location_obj.name + "-" + next_location_obj.name
                              }
            activities.append(trans_act_dict)

            curr_startTime = trans_endTime + timedelta(minutes=10)

        # json序列化
        activities_str = activities.__str__()
        activities_str = json.dumps(activities, ensure_ascii=False)
        end_date = curr_startTime.date()
        # print(activities_str)
        trip = TripModel.objects.create(
            creator=user_obj,
            departure=dest_obj,
            activities=activities_str,
            endDate=end_date,
            **validated_data)
        return trip
