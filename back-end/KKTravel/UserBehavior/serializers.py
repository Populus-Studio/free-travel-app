from DestinationService.models import DestinationModel, LocationModel
from rest_framework import serializers

from UserAuth.models import UserModel
from UserBehavior.models import UserBehaviorModel


class UserBehaviorSerializer(serializers.ModelSerializer):
    # 定位用户模型
    username = serializers.CharField(write_only=True)
    # 定位地点模型
    siteId = serializers.IntegerField(write_only=True)

    class Meta:
        model = UserBehaviorModel
        fields = ['id', 'username', 'siteId', 'behaviorType', 'behaviorBool',
                  'behaviorWeight', 'contextTime', 'contextLocation']

    def create(self, validated_data):
        user_obj = UserModel.objects.filter(username=validated_data.pop('username')).first()
        site_obj = LocationModel.objects.filter(id=validated_data.pop('siteId')).first()

        behavior = UserBehaviorModel.objects.create(user=user_obj,site=site_obj,**validated_data)
        return behavior

