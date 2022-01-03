from KKTravel.settings import WECHAT_AUTH

import requests
from django.http import Http404
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.renderers import JSONRenderer

import UserAuth.serializers
from UserAuth.models import UserModel
from UserAuth.serializers import UserRegistSerializer, UserLoginInfoSerializer

# 使用APIView代替之前的api_view，这将是我们继承的基类
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics


def is_user_exists(username):
    return UserModel.objects.filter(username=username).exists()


class CheckUserNameExists(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        username = request.query_params.get('username')
        if is_user_exists(username):
            return Response({"result": True}, status=status.HTTP_200_OK)
        else:
            return Response({"result": False}, status=status.HTTP_200_OK)


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


class UserLoginWechat(APIView):
    """
    使用JWT的方式登录
    """
    permission_classes = {}
    authentication_classes = {}

    # 微信后台appid和secret，该字段测试完成后应转移到setting.py文件中
    APPID = WECHAT_AUTH.get('APPID')
    SECRET = WECHAT_AUTH.get('SECRET')

    def post(self, request):
        # 获得前端传来的微信请求Code
        code = request.data.get('code')

        try:
            # 请求微信后端获取 登录信息
            wechat_url = requests.get(
                f"https://api.weixin.qq.com/sns/oauth2/access_token?appid={self.APPID}&secret={self.SECRET}&code={code}&grant_type=authorization_code")
            info = wechat_url.json()
            open_id = info.get('openid')
            access_token = info.get('access_token')

            # 请求微信后端获取 用户信息
            user_info_req = requests.get(
                f'https://api.weixin.qq.com/sns/userinfo?access_token={access_token}&openid={open_id}&lang=zh_CN')
            user_info_req.encoding = 'utf-8'
            user_info = user_info_req.json()
        except Exception:
            raise AuthenticationFailed("认证失败")

        res_data = {
            'token': None,
            'openid': open_id,
            'username': None
        }

        # 从微信返回的用户信息中获取微信昵称，查找对应用户是否存在
        if is_user_exists(user_info.get('nickname')):
            # 用户存在，返回登录信息
            user_model = UserModel.objects.get(username=user_info.get('nickname'))
            res_data['token'] = UserAuth.serializers.create_token(user_model)
            res_data['username'] = user_model.username
            return Response(JSONRenderer().render(res_data), status=status.HTTP_200_OK)

        else:
            # 用户不存在，新建用户
            userdata = {
                'username': user_info.get('nickname'),
                'password': open_id,  # 暂时默认以open_id作为密码
                'openid': open_id,
                'phoneNumber': None
            }
            user = UserRegistSerializer(data=userdata)
            if user.is_valid():
                user.save()
                res_data['token'] = user.data.get('token')
                res_data['username'] = user.data.get('username')
                return Response(JSONRenderer().render(res_data), status=status.HTTP_201_CREATED)
            else:
                return Response(user.errors, status=status.HTTP_400_BAD_REQUEST)
