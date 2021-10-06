from django.urls import path
from rest_framework_jwt.views import obtain_jwt_token
from rest_framework.authtoken.views import obtain_auth_token

import UserAuth.views as views

urlpatterns = [
    path('auth/login/registered', obtain_jwt_token),
    path('auth/regist', views.UserRegist.as_view()),
    # 使用hyperlink作为序列化方式的，要在path上加入参数name
    path('auth/user/<int:pk>/', views.UserManager.as_view(), name='usermodel-detail')
]
