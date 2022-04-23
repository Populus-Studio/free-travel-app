from django.shortcuts import render
from rest_framework.permissions import AllowAny

from UserAuth.models import UserModel
from UserBehavior.serializers import UserBehaviorSerializer
from UserBehavior.models import UserBehaviorModel
# 使用APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import HttpResponse, StreamingHttpResponse
from datetime import datetime
import csv


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


class UserBehaviorDataDownload(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        response = HttpResponse(content_type="text/csv")
        response['Content-Disposition'] = "attachment;filename=userBehaviorLog.csv"
        all_obj = UserBehaviorModel.objects.all()

        writer = csv.writer(response)
        writer.writerow(['user_id', 'time', 'latitude', 'longitude', 'location_id'])
        for obj in all_obj:
            user_id = "\'" + str(obj.user.id) + "\'"
            print(user_id)
            site_name = "\'" + str(obj.site.name) + "\'"
            print(site_name)
            timestamp = int(obj.contextTime.timestamp())
            geo_str_pair = str(obj.contextLocation).split(',')
            latitude = float(geo_str_pair[0])
            longitude = float(geo_str_pair[1])
            writer.writerow([user_id, timestamp, latitude, longitude, site_name])

        return response
