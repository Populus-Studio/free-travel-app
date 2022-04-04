from django.db import models
from DestinationService.models import DestinationModel
from UserAuth.models import UserModel


# 行程数据模型
class TripModel(models.Model):
    name = models.CharField(max_length=200)
    # 创建者：用户名的引用
    creator = models.ForeignKey(UserModel, related_name="trip_creator", on_delete=models.CASCADE)
    # 是否为收藏状态
    isFavorite = models.BooleanField(default=False)
    # 是否为推荐状态
    isRecommend = models.BooleanField(default=False)

    # 行程状态（0：未出发，1：进行中，2：已完成）
    # PS: choice 必须选择二元组组成的列表（元组），第一位表示数据库中的存储值，第二位表示在渲染网页表单时的展示值
    status = models.IntegerField(choices=((0, 'in_future'),
                                          (1, 'on_going'),
                                          (2, 'finished'),),
                                 default=0)
    # 出发地：目的地模型的引用
    departure = models.ForeignKey(DestinationModel, related_name="trip_departure", on_delete=models.CASCADE)
    # 行程描述
    description = models.TextField(blank=True)
    # 行程人数
    numOfTourists = models.IntegerField(default=0)
    # 开始和结束日期
    startDate = models.DateField()
    endDate = models.DateField()
    # 持续时间（天）
    duration = models.IntegerField(default=0)
    # 备注文本
    remarks = models.TextField(blank=True)
    # 头图url
    img_url = models.URLField(blank=True)
    # 使用json格式字符串文本存储行程中包含的活动信息
    activities = models.TextField(default="")
    # 活动总数
    # numberOfActivities = models.IntegerField(default=0)
    # 总计花费
    # totalCost = models.IntegerField(default=0)
