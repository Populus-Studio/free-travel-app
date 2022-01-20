from django.contrib.auth.hashers import make_password
from rest_framework_jwt.settings import api_settings

from UserAuth.models import UserModel
from rest_framework import serializers


# 使用REST framework JWT 生成token
def create_token(user):
    jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
    jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER
    payload = jwt_payload_handler(user)
    token = jwt_encode_handler(payload)

    return token


# 处理用户注册的序列化类
class UserRegistSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()
    openid = serializers.CharField(required=False, allow_blank=True)
    phoneNumber = serializers.CharField(required=False, allow_blank=True)
    token = serializers.CharField(read_only=True)

    def create(self, validated_data):
        user = UserModel.objects.create(**validated_data)
        password = make_password(validated_data.get("password"))
        user.password = password
        user.save()
        user.token = create_token(user)
        return user


# 获取用户信息的序列化类
class UserLoginInfoSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = UserModel
        fields = ['url', 'username', 'openid', 'phoneNumber']
