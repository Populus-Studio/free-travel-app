from DestinationService.models import DestinationModel, LocationModel, LocationFavorModel
from rest_framework import serializers

# from drf_writable_nested import WritableNestedModelSerializer
from UserAuth.models import UserModel


class DestinationSerializer(serializers.ModelSerializer):
    class Meta:
        model = DestinationModel
        fields = ['id', 'name', 'description', 'parent']


class LocationSerializer(serializers.ModelSerializer):
    # 目的地（模型）的嵌套序列化引用
    # 为实现嵌套引用，必须将many属性设置为True，并且在Model中定义外键时，
    # 添加相应名称的“related_name"属性
    # destination = DestinationSerializer(many=True)

    # 由于是一对多关系，不使用嵌套序列化引用了，改为传入id来定位目的地模型
    destination_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = LocationModel
        fields = ['id', 'name', 'label', 'type', 'destination_id',
                  'address', 'description', 'cost', 'timeCost',
                  'rate', 'heat', 'opentime', 'img_url']

    def create(self, validated_data):
        dest_obj = DestinationModel.objects.filter(id=validated_data.pop('destination_id')).first()
        location = LocationModel.objects.create(destination=dest_obj, **validated_data)
        return location

# 用户收藏地点的模型（两个外键
class LocationFavorSerializer(serializers.ModelSerializer):
    # 定位用户模型（只写，TODO：可用HiddenField简化）
    username = serializers.CharField(write_only=True)
    # 定位地点模型（可读可写）
    siteId = serializers.IntegerField(source="site.id")

    class Meta:
        model = LocationFavorModel
        fields = ['id', 'username', "siteId"]

    def create(self, validated_data):
        user_obj = UserModel.objects.filter(username=validated_data.pop('username')).first()
        site_obj = LocationModel.objects.filter(id=validated_data.pop('site')['id']).first()

        favor_record = LocationFavorModel.objects.create(user=user_obj, site=site_obj, **validated_data)
        return favor_record
