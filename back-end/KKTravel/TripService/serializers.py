from DestinationService.models import DestinationModel, LocationModel
from TripService.models import TripModel
import json
from rest_framework import serializers

from UserAuth.models import UserModel


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
