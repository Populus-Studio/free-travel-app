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
    def get(self, request):
        # 所有的可查询参数
        is_favor = request.query_params.dict().isFavorite
        is_recommend = request.query_params.dict().recommended
        is_future = request.query_params.dict().future
        is_ongoing = request.query_params.dict().ongoing
        is_finished = request.query_params.dict().finished
        keywords = request.query_params.dict().keywords

        print("favor:%s, recommend:%s, status: %s %s %s, keyword: %s" %
              (is_favor, is_recommend, is_future, is_ongoing, is_finished, keywords))
        print(type(is_favor), type(is_future), type(keywords))

        query_status = [0, 1, 2]
        if is_future:
            query_status = [0]
        elif is_ongoing:
            query_status = [1]
        elif is_finished:
            query_status = [2]

        trips_all = TripModel.objects.all()
        if keywords != "":
            trips = trips_all.filter(isFavorite=is_favor,
                                     isRecommend=is_recommend,
                                     status__in=query_status,
                                     name__contains=keywords)
        else:
            trips = trips_all.filter(isFavorite=is_favor,
                                     isRecommend=is_recommend,
                                     status__in=query_status)
        trips = trips.order_by("startDate", reversed=True)
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

    def get_trip_object(self, pk):
        try:
            return TripModel.objects.get(pk=pk)
        except TripModel.DoesNotExist:
            raise Http404

    # 获取单一行程
    def get(self, request, pk):
        trip_obj = self.get_trip_object(pk)
        trip_serializer = TripSerializer(trip_obj)
        res_data = {
            "trip": trip_serializer.data
        }
        return Response(res_data, status=status.HTTP_200_OK)

    # 修改单一行程
    def put(self, request, pk):
        trip_obj = self.get_trip_object(pk)
        trip_serializer = TripSerializer(trip_obj, data=request.data)
        if trip_serializer.is_valid():
            trip_serializer.save()
            return Response(trip_serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(trip_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # 删除单一行程
    def delete(self, request, pk):
        trip_obj = self.get_trip_object(pk)
        trip_obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
