import json

from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_jwt.authentication import JSONWebTokenAuthentication

from UserAuth.models import UserModel
from UserAuth.serializers import UserRegistSerializer, UserLoginInfoSerializer

# 使用APIView代替之前的api_view，这将是我们继承的基类
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics


class UserRegist(APIView):
    # 取消全局权限，允许所有人访问
    permission_classes = [AllowAny]

    def post(self, request):
        data = request.data
        try:
            user = UserRegistSerializer(data=data)
            if user.is_valid():
                user.save()
                res_data = {
                    "code": 0,
                    "msg": "创建成功",
                    "data": user.data
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
            return Response(user.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "创建失败,错误码 " + str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)


class UserManager(generics.RetrieveUpdateDestroyAPIView):
    queryset = UserModel.objects.all()
    serializer_class = UserLoginInfoSerializer
    # 局部权限判定示例
    permission_classes = [IsAuthenticated]
    authentication_classes = [JSONWebTokenAuthentication]


def login_return(token, user=None, request=None):
    return {
        'token': token,
        'username': user.username
    }

