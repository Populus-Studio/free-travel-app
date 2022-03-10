from django.core.paginator import Paginator, PageNotAnInteger, EmptyPage
from django.http import JsonResponse
from rest_framework import status


def api_paging(objs, request, Serializer, dto_name):
    """
    objs : 要返回的实体对象列表
    request : 请求对象
    Serializer : 实体对象对应的序列化类（用于序列化）
    dto_name: 返回时列表的前缀名
    """
    try:
        page_size = int(request.query_params.dict()['size'])
        page = int(request.query_params.dict()['page'])
    except (TypeError, ValueError):
        res_data = {
            "code": 400,
            "msg": "page and page_size must be integer"
        }
        return JsonResponse(res_data, status=status.HTTP_400_BAD_REQUEST)

    paginator = Paginator(objs, page_size)  # 创建paginator对象
    total = paginator.num_pages  # 总页数
    try:
        objs = paginator.page(page)
    except PageNotAnInteger:
        objs = paginator.page(1)
    except EmptyPage:
        objs = paginator.page(paginator.num_pages)

    serializer = Serializer(objs, many=True)  # 序列化操作

    return JsonResponse({
        "_embedded": {
            (dto_name + "DtoList"): serializer.data
        },
        'page': {
            'totalPages': total,
            'size': page_size,
            'number': page
        }
    }, status=status.HTTP_200_OK)
