from rest_framework.permissions import AllowAny

from DestinationService.models import DestinationModel, LocationModel
from DestinationService.serializers import DestinationSerializer, LoactionSerializer

# 使用APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import Http404


# B1-2（暂未实现查询功能）
class DestinationListManager(APIView):
    def get(self, request):
        keywords = request.query_params.dict().search
        sortBy = request.query_params.dict().sortBy
        order = request.query_params.dict().order

        print("keyword: %s" % keywords)
        print(type(keywords))

        # 筛选查询关键词
        destinations = DestinationModel.objects.all()
        if keywords != "":
            destinations = destinations.filter(name__contains=keywords)
        if sortBy != "" and order != "":
            if order == "ASC":
                destinations = destinations.order_by(sortBy)
            elif order == "DESC":
                destinations = destinations.order_by(sortBy, reversed=True)
            else:
                res_data = {
                    "code": 400,
                    "msg": "order参数错误，请检查"
                }
                return Response(res_data, status=status.HTTP_400_BAD_REQUEST)

        dests_serializer = DestinationSerializer(destinations, many=True)
        return Response(dests_serializer.data, status=status.HTTP_200_OK)


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
                    "msg": "新增目的地成功"
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
            else:
                return Response(dest_post.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "新增目的地失败,错误码 " + str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)


# B2-2（暂未实现查询功能）
class LocationListManager(APIView):
    def get(self, request, format=None):
        locations = LocationModel.objects.all()
        locas_serializer = LoactionSerializer(locations, many=True)
        return Response(locas_serializer.data)


# B2-1
class LocationSingleManager(APIView):
    def get(self, request, pk):
        loca_obj = None
        try:
            loca_obj = LocationModel.objects.get(pk=pk)
        except LocationModel.DoesNotExist:
            raise Http404
        loca_serializer = LoactionSerializer(loca_obj)
        res_data = {
            "site": loca_serializer.data
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
            loca_post = LoactionSerializer(data=data)
            if loca_post.is_valid():
                loca_post.save()
                res_data = {
                    "code": 201,
                    "msg": "新增地点成功"
                }
                return Response(res_data, status=status.HTTP_201_CREATED)
            else:
                return Response(loca_post.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e)
            res_data = {
                "code": 409,
                "msg": "新增地点失败,错误码 " + str(e)
            }
            return Response(res_data, status=status.HTTP_409_CONFLICT)


# B3-1 & B3-2
class RecommendManager(APIView):
    pass
