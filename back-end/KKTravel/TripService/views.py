from django.shortcuts import render
from TripService.models import TripModel
from TripService.serializers import TripSerializer
# 使用APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import Http404


# D1-1 & D1-5
class TripGlobalManager(APIView):
    # 批量获取行程
    def get(self, request, format=None):
        trips = TripModel.objects.all()
        trips_serializer = TripSerializer(trips, many=True)
        return Response(trips_serializer.data)

    # 自动生成行程
    def post(self, request):
        data = request.data
        try:
            trip_post = TripSerializer(data=data)
            if trip_post.is_valid():
                trip_post.save()
                res_data = {
                    "code": 201,
                    "msg": "创建行程成功"
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
            else:
                return Response(trip_post.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "创建行程失败,错误码 " + str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)


# D1-2 to D1-4
class TripSingleManager(APIView):
    # 获取单一行程
    def get(self, request, pk):
        trip_obj = None
        try:
            trip_obj = TripModel.objects.get(pk=pk)
        except TripModel.DoesNotExist:
            raise Http404
        trip_serializer = TripSerializer(trip_obj)
        res_data = {
            "trip": trip_serializer.data
        }
        return Response(res_data, status=status.HTTP_200_OK)

    # 修改单一行程
    def put(self, request, pk):
        pass

    # 删除单一行程
    def delete(self, request, pk):
        pass
