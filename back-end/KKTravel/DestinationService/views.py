from rest_framework.permissions import AllowAny

from DestinationService.models import DestinationModel, LocationModel, LocationFavorModel
from DestinationService.serializers import DestinationSerializer, LocationSerializer, LocationFavorSerializer

# 使用APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import Http404

# 使用自定义paging
from UserAuth.models import UserModel
from Utils.paging import api_paging


# B1-2
class DestinationListManager(APIView):
    def get(self, request):
        print(request.query_params.dict())
        keywords = request.query_params.dict()['search']
        sortBy = request.query_params.dict()['sortBy']
        order = request.query_params.dict()['order']

        # 筛选查询关键词
        destinations = DestinationModel.objects.all()
        if keywords != "":
            destinations = destinations.filter(name__contains=keywords)
        if sortBy != "" and order != "":
            if order == "ASC":
                destinations = destinations.order_by(sortBy)
            elif order == "DESC":
                destinations = destinations.order_by("-" + sortBy)
            else:
                res_data = {
                    "code": 400,
                    "msg": "order参数错误，请检查"
                }
                return Response(res_data, status=status.HTTP_400_BAD_REQUEST)

        # dests_serializer = DestinationSerializer(destinations, many=True)
        # res_data = {
        #     "_embedded": {
        #         "destinationDtoList": dests_serializer.data}
        # }
        return api_paging(destinations, request, DestinationSerializer, "destination")


# B1-1
class DestinationSingleManager(APIView):
    def get(self, request, pk):
        dest_obj = None
        try:
            dest_obj = DestinationModel.objects.get(pk=pk)
        except DestinationModel.DoesNotExist:
            raise Http404
        dest_serializer = DestinationSerializer(dest_obj)
        res_data = {
            "code": 200,
            "msg": "获取目的地成功",
            "destination": dest_serializer.data
        }
        return Response(res_data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        pass

    def delete(self, request, pk):
        pass


# 内部使用：增加目的地的接口
class DestinationMutiAdd(APIView):
    permission_classes = [AllowAny]

    def post(self, request, format=None):
        data = request.data
        try:
            dest_post = DestinationSerializer(data=data)
            if dest_post.is_valid():
                dest_post.save()
                res_data = {
                    "code": 201,
                    "msg": "新增目的地成功",
                    "data": dest_post.data
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
            else:
                return Response(dest_post.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "新增目的地失败",
                "detail": str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)


# B2-2
class LocationListManager(APIView):
    def get(self, request, format=None):
        keywords = request.query_params.dict()['search']
        sortBy = request.query_params.dict()['sortBy']
        order = request.query_params.dict()['order']

        # 筛选查询关键词
        locations = LocationModel.objects.all()
        if keywords != "":
            locations = locations.filter(name__contains=keywords)
        if sortBy != "" and order != "":
            if order == "ASC":
                locations = locations.order_by(sortBy)
            elif order == "DESC":
                locations = locations.order_by("-" + sortBy)
            else:
                res_data = {
                    "code": 400,
                    "msg": "order参数错误，请检查"
                }
                return Response(res_data, status=status.HTTP_400_BAD_REQUEST)

        # locas_serializer = LoactionSerializer(locations, many=True)
        # res_data = {
        #     "_embedded": {
        #         "siteDtoList": locas_serializer.data}
        # }
        return api_paging(locations, request, LocationSerializer, "site")


# B2-1
class LocationSingleManager(APIView):
    def get(self, request, pk):
        loca_obj = None
        is_favor = False
        try:
            loca_obj = LocationModel.objects.get(pk=pk)
        except LocationModel.DoesNotExist:
            raise Http404
        loca_serializer = LocationSerializer(loca_obj)
        favor_record = LocationFavorModel.objects.filter(user=request.user, site=loca_obj)
        if len(favor_record) > 0:
            is_favor = True
        res_data = {
            "code": 200,
            "msg": "获取地点成功",
            "site": loca_serializer.data,
            "isFavorite": is_favor
        }
        return Response(res_data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        pass

    def delete(self, request, pk):
        pass


# 内部使用：增加地点的接口
class LocationMutiAdd(APIView):
    permission_classes = [AllowAny]

    def post(self, request, format=None):
        data = request.data
        try:
            loca_post = LocationSerializer(data=data)
            if loca_post.is_valid():
                loca_post.save()
                res_data = {
                    "code": 201,
                    "msg": "新增地点成功",
                    "data": loca_post.data
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
            else:
                return Response(loca_post.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "新增地点失败",
                "detail": str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)


# B2-3 & B3-1 & B3-2
class LocationFavorManager(APIView):
    def get(self, request):
        favor_objs = LocationFavorModel.objects.filter(user=request.user)

        favor_records = LocationFavorSerializer(favor_objs, many=True)
        favor_sites = []
        for r in favor_records.data:
            site = LocationModel.objects.filter(id=r['siteId']).first()
            favor_sites.append(site)
        favor_res_serializer = LocationSerializer(favor_sites, many=True)
        res_data = {
            "code": 200,
            "msg": "获得所有收藏地点成功",
            "data": favor_res_serializer.data
        }
        return Response(res_data, status=status.HTTP_200_OK)

    def post(self, request):
        data = request.data
        site_favor_post = LocationFavorSerializer(data=data)
        if site_favor_post.is_valid():
            user_obj = request.user
            site_obj = LocationModel.objects.filter \
                (id=site_favor_post.validated_data['site']['id']).first()
            record = LocationFavorModel.objects.filter(user=user_obj, site=site_obj).first()
            if record != None:
                res_data = {
                        "code": 409,
                        "msg": "收藏失败，该地点已被收藏",
                        "detail": site_favor_post.data
                    }
                return Response(res_data, status=status.HTTP_409_CONFLICT)
            else:
                site_favor_post.save()
                res_data = {
                    "code": 201,
                    "msg": "收藏成功",
                    "data": site_favor_post.data
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
        else:
            return Response(site_favor_post.errors, status=status.HTTP_400_BAD_REQUEST)


    def delete(self, request):
        data = request.data
        try:
            site_favor_serializer = LocationFavorSerializer(data=data)
            if site_favor_serializer.is_valid():
                user_obj = request.user
                site_obj = LocationModel.objects.filter \
                    (id=site_favor_serializer.validated_data['site']['id']).first()
                record = LocationFavorModel.objects.filter(user=user_obj, site=site_obj).first()
                record.delete()
                res_data = {
                    "code": 204,
                    "msg": "取消收藏成功",
                    "data": site_favor_serializer.data
                }
                return Response(res_data, status=status.HTTP_204_NO_CONTENT)
            else:
                return Response(site_favor_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "取消收藏失败",
                "detail": str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)
