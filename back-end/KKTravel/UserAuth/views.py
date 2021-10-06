import json

from django.http import Http404
from rest_framework.permissions import IsAuthenticated, AllowAny

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


class UserManager(APIView):
    # 局部权限判定示例
    # permission_classes = [IsAuthenticated]
    # authentication_classes = [JSONWebTokenAuthentication]

    # 这是一个私有函数，使用时记得要加上前缀`self.`
    def get_object(self, pk):
        try:
            return UserModel.objects.get(pk=pk)
        except UserModel.DoesNotExist:
            raise Http404

    def get(self, request, pk):
        try:
            user = self.get_object(pk)
            if request.user != user:
                res_data = {
                    "code": 403,
                    "msg": "禁止访问"
                }
                return Response(res_data, status=status.HTTP_403_FORBIDDEN)
            # 使用hyperlink作为序列化方式时，构造序列化类对象需要添加参数context={'request': request}
            user_ser = UserLoginInfoSerializer(user, context={'request': request})
            res_data = {
                "user": user_ser.data
            }
            return Response(res_data, status=status.HTTP_200_OK)
        except Http404 as e:
            res_data = {
                "code": 404,
                "msg": "用户未找到 " + str(e)
            }
            return Response(res_data, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, pk):
        user = self.get_object(pk)
        if request.user != user:
            res_data = {
                "code": 403,
                "msg": "禁止访问"
            }
            return Response(res_data, status=status.HTTP_403_FORBIDDEN)
        pass

    def delete(self, request, pk):
        user = self.get_object(pk)
        if request.user != user:
            res_data = {
                "code": 403,
                "msg": "禁止访问"
            }
            return Response(res_data, status=status.HTTP_403_FORBIDDEN)
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
