from django.shortcuts import render
from TripService.models import TripModel
from TripService.serializers import TripSerializer, TripSmartSerializer
from UserAuth.models import UserModel
from datetime import date
# 使用APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import Http404,HttpResponseBadRequest

# 使用自定义paging
from Utils.paging import api_paging


# D1-1 & D1-6
class TripGlobalManager(APIView):
    # 批量获取所有行程
    def get(self, request):
        query_dict = request.query_params.dict()
        if 'isFavorite' in query_dict:
            is_favor = request.query_params.dict()['isFavorite']
        else:
            is_favor = "0"

        if 'recommended' in query_dict:
            is_recommend = request.query_params.dict()['recommended']
        else:
            is_recommend = "0"

        if 'future' in query_dict:
            is_future = request.query_params.dict()['future']
        else:
            is_future = "0"

        if 'ongoing' in query_dict:
            is_ongoing = request.query_params.dict()['ongoing']
        else:
            is_ongoing = "0"

        if 'finished' in query_dict:
            is_finished = request.query_params.dict()['finished']
        else:
            is_finished = "0"

        if 'keywords' in query_dict:
            keywords = request.query_params.dict()['keywords']
        else:
            keywords = ""

        if 'page' not in query_dict or 'size' not in query_dict:
            return HttpResponseBadRequest

        # 查询列表，数据库只返回 符合”对应属性在查询列表中“ 的条目
        query_favor = [0, 1]
        query_recommend = [0, 1]

        if is_favor == "1":
            query_favor = [1]

        if is_recommend == "1":
            query_recommend = [1]

        trips_all = TripModel.objects.all()
        today_date = date.today()

        if keywords != "":
            trips = trips_all.filter(isFavorite__in=query_favor,
                                     isRecommend__in=query_recommend,
                                     name__contains=keywords)
        else:
            trips = trips_all.filter(isFavorite__in=query_favor,
                                     isRecommend__in=query_recommend)
        if is_future == "1":
            trips = trips.filter(startDate__gt=today_date)
        elif is_ongoing == "1":
            trips = trips.filter(startDate__lte=today_date,
                                 endDate__gte=today_date)
        elif is_finished == "1":
            trips = trips.filter(endDate__lt=today_date)

        # # 按照指定属性排列
        # if order == "ASC":
        #     trips = trips.order_by(sortBy)
        # elif order == "DESC":
        #     trips = trips.order_by("-" + sortBy)
        # else:
        #     res_data = {
        #         "code": 400,
        #         "msg": "order参数错误，请检查"
        #     }
        #     return Response(res_data, status=status.HTTP_400_BAD_REQUEST)

        return api_paging(trips, request, TripSerializer, "trip")

    # 自动生成行程
    def post(self, request):
        data = request.data
        trip_post = TripSerializer(data=data)
        if trip_post.is_valid():
            user_obj = UserModel.objects.filter(username=trip_post.validated_data['username']).first()
            if request.user != user_obj:
                res_data = {
                    "code": 403,
                    "msg": "当前用户无权限修改行程"
                }
                return Response(res_data, status=status.HTTP_403_FORBIDDEN)
            # if trip_post.validated_data['id']
            trip_post.save()
            res_data = {
                "code": 201,
                "msg": "创建行程成功",
                "data": trip_post.data
            }
            return Response(res_data, status=status.HTTP_201_CREATED)
        else:
            return Response(trip_post.errors, status=status.HTTP_400_BAD_REQUEST)


class TripSmartGenerate(APIView):
    def post(self, request):
        data = request.data
        trip_post = TripSmartSerializer(data=data)
        if trip_post.is_valid():
            user_obj = UserModel.objects.filter(username=trip_post.validated_data['username']).first()
            if request.user != user_obj:
                res_data = {
                    "code": 403,
                    "msg": "当前用户无权限生成行程"
                }
                return Response(res_data, status=status.HTTP_403_FORBIDDEN)

            trip_post.save()
            trip_post_obj = get_trip_object(pk=trip_post.data['id'])
            res_data = {
                "code": 201,
                "msg": "生成行程成功",
                "data": TripSerializer(trip_post_obj).data
            }
            return Response(res_data, status=status.HTTP_201_CREATED)
        else:
            return Response(trip_post.errors, status=status.HTTP_400_BAD_REQUEST)


# D1-5
class TripForUserManager(APIView):
    # 批量获取 当前登录用户 的所有行程
    def get(self, request):
        # 所有的可查询参数
        query_dict = request.query_params.dict()
        if 'isFavorite' in query_dict:
            is_favor = request.query_params.dict()['isFavorite']
        else:
            is_favor = "0"

        if 'recommended' in query_dict:
            is_recommend = request.query_params.dict()['recommended']
        else:
            is_recommend = "0"

        if 'future' in query_dict:
            is_future = request.query_params.dict()['future']
        else:
            is_future = "0"

        if 'ongoing' in query_dict:
            is_ongoing = request.query_params.dict()['ongoing']
        else:
            is_ongoing = "0"

        if 'finished' in query_dict:
            is_finished = request.query_params.dict()['finished']
        else:
            is_finished = "0"

        if 'keywords' in query_dict:
            keywords = request.query_params.dict()['keywords']
        else:
            keywords = ""
        if 'page' not in query_dict or 'size' not in query_dict:
            return HttpResponseBadRequest

        # print("favor:%s, recommend:%s, status: %s %s %s, keyword: %s" %
        #       (is_favor, is_recommend, is_future, is_ongoing, is_finished, keywords))
        # print(type(is_favor), type(is_future), type(keywords))
        # 查询列表，数据库只返回 符合”对应属性在查询列表中“ 的条目
        query_favor = [0, 1]
        query_recommend = [0, 1]

        if is_favor == "1":
            query_favor = [1]

        if is_recommend == "1":
            query_recommend = [1]

        trips_all = TripModel.objects.filter(creator=request.user)
        today_date = date.today()

        if keywords != "":
            trips = trips_all.filter(isFavorite__in=query_favor,
                                     isRecommend__in=query_recommend,
                                     name__contains=keywords)
        else:
            trips = trips_all.filter(isFavorite__in=query_favor,
                                     isRecommend__in=query_recommend)
        if is_future == "1":
            trips = trips.filter(startDate__gt=today_date)
        elif is_ongoing == "1":
            trips = trips.filter(startDate__lte=today_date,
                                 endDate__gte=today_date)
        elif is_finished == "1":
            trips = trips.filter(endDate__lt=today_date)



        # 按照出发时间倒序排列
        trips = trips.order_by("-startDate")

        return api_paging(trips, request, TripSerializer, "trip")


# D1-2 to D1-4
def get_trip_object(pk):
    try:
        return TripModel.objects.get(pk=pk)
    except TripModel.DoesNotExist:
        raise Http404


class TripSingleManager(APIView):

    # 获取单一行程
    def get(self, request, pk):
        trip_obj = get_trip_object(pk)
        trip_serializer = TripSerializer(trip_obj)
        res_data = {
            "code": 200,
            "msg": "获取行程成功",
            "trip": trip_serializer.data
        }
        return Response(res_data, status=status.HTTP_200_OK)

    # 修改单一行程
    def put(self, request, pk):
        trip_obj = get_trip_object(pk)
        trip_serializer = TripSerializer(trip_obj, data=request.data)
        if trip_serializer.is_valid():
            user_obj = UserModel.objects.filter(username=trip_serializer.validated_data.pop('username')).first()
            if request.user != user_obj:
                res_data = {
                    "code": 403,
                    "msg": "当前用户无权限修改行程"
                }
                return Response(res_data, status=status.HTTP_403_FORBIDDEN)
            else:
                trip_serializer.save()
                res_data = {
                    "code": 201,
                    "msg": "行程修改成功",
                    "data": trip_serializer.data
                }
                return Response(res_data, status=status.HTTP_200_OK)
        else:
            res_data = {
                "code": 400,
                "msg": "行程修改失败",
                "data": trip_serializer.errors
            }
            return Response(res_data, status=status.HTTP_400_BAD_REQUEST)

    # 删除单一行程
    def delete(self, request, pk):
        trip_obj = get_trip_object(pk)
        trip_obj.delete()
        res_data = {
            "code": 204,
            "msg": "行程删除成功"
        }
        return Response(res_data, status=status.HTTP_204_NO_CONTENT)


class TripFavorManager(APIView):

    def post(self, request, pk):
        trip_obj = get_trip_object(pk)
        trip_serializer = TripSerializer(trip_obj)

        user_obj = UserModel.objects.filter(id=trip_obj.creator_id).first()
        if request.user != user_obj:
            res_data = {
                "code": 403,
                "msg": "当前用户无权限修改行程"
            }
            return Response(res_data, status=status.HTTP_403_FORBIDDEN)
        elif trip_serializer.data['isFavorite']:
            res_data = {
                "code": 409,
                "msg": "收藏失败，该行程已收藏"
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)
        else:
            trip_serializer = TripSerializer(trip_obj, data={'isFavorite': True}, partial=True)
            if trip_serializer.is_valid():
                trip_serializer.save()
                res_data = {
                    "code": 200,
                    "msg": "收藏成功",
                    "data": trip_serializer.data
                }
                return Response(res_data, status=status.HTTP_200_OK)
            else:
                res_data = {
                    "code": 400,
                    "msg": "数据校验未通过",
                    "detail": trip_serializer.errors
                }
                return Response(res_data, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        trip_obj = get_trip_object(pk)
        trip_serializer = TripSerializer(trip_obj)

        user_obj = UserModel.objects.filter(id=trip_obj.creator_id).first()
        if request.user != user_obj:
            res_data = {
                "code": 403,
                "msg": "当前用户无权限修改行程"
            }
            return Response(res_data, status=status.HTTP_403_FORBIDDEN)
        elif not trip_serializer.data['isFavorite']:
            res_data = {
                "code": 409,
                "msg": "取消收藏失败，该行程未被收藏"
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)
        else:
            trip_serializer = TripSerializer(trip_obj, data={'isFavorite': False}, partial=True)
            if trip_serializer.is_valid():
                trip_serializer.save()
                res_data = {
                    "code": 200,
                    "msg": "取消收藏成功",
                    "data": trip_serializer.data
                }
                return Response(res_data, status=status.HTTP_200_OK)
            else:
                res_data = {
                    "code": 400,
                    "msg": "数据校验未通过",
                    "detail": trip_serializer.errors
                }
                return Response(res_data, status=status.HTTP_400_BAD_REQUEST)
