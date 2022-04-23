from DestinationService.models import DestinationModel, LocationModel
from rest_framework import serializers

from UserAuth.models import UserModel
from UserBehavior.models import UserBehaviorModel
from Utils.geocode import get_geocode


class UserBehaviorSerializer(serializers.ModelSerializer):
    # 定位用户模型
    username = serializers.CharField(write_only=True)
    # 定位地点模型
    siteId = serializers.IntegerField(write_only=True)

    class Meta:
        model = UserBehaviorModel
        fields = ['id', 'username', 'siteId', 'behaviorType', 'behaviorBool',
                  'behaviorWeight', 'contextTime']

    def create(self, validated_data):
        user_obj = UserModel.objects.filter(username=validated_data.pop('username')).first()
        site_obj = LocationModel.objects.filter(id=validated_data.pop('siteId')).first()

        geocode = get_geocode(site_obj.address)

        behavior = UserBehaviorModel.objects.create(user=user_obj, site=site_obj, contextLocation=geocode, **validated_data)
        return behavior

