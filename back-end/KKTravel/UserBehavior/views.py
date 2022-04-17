from django.shortcuts import render

from UserAuth.models import UserModel
from UserBehavior.serializers import UserBehaviorSerializer
from UserBehavior.models import UserBehaviorModel
# 使用APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import Http404

from Utils.paging import api_paging


class UserBehaviorGlobalManager(APIView):
    def post(self, request):
        data = request.data
        behavior_post = UserBehaviorSerializer(data=data)

        if behavior_post.is_valid():
            behavior_post.save()
            res_data = {
                "code": 201,
                "msg": "上传行为数据成功",
                "data": behavior_post.data
            }
            return Response(res_data, status=status.HTTP_201_CREATED)
        else:
            return Response(behavior_post.errors, status=status.HTTP_201_CREATED)


class UserBehaviorSingleManager(APIView):
    def get(self, request, pk):
        user_obj = UserModel.objects.get(pk=pk)
        behaviors_all = UserBehaviorModel.objects.filter(user=user_obj)
        behaviors_all = behaviors_all.order_by("-contextTime")

        return api_paging(behaviors_all, request, UserBehaviorSerializer, "UserBehavior")
