from DestinationService.models import DestinationModel, LocationModel
from rest_framework import serializers
# from drf_writable_nested import WritableNestedModelSerializer


class DestinationSerializer(serializers.ModelSerializer):
    class Meta:
        model = DestinationModel
        fields = ['id', 'name', 'description', 'parent']



class LoactionSerializer(serializers.ModelSerializer):
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

