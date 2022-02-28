from django.db import models
from DestinationService.models import DestinationModel
from UserAuth.models import UserModel


# 行程数据模型

class TripModel(models.Model):
    name = models.CharField(max_length=200)
    # 创建者：用户名的引用
    creator = models.ForeignKey(UserModel, related_name="trip_creator", on_delete=models.CASCADE)
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
    remarks = models.TextField(blank=True)
    img_url = models.URLField(blank=True)
    # 使用json格式文本存储行程中包含的活动信息
    activities = models.TextField()
    # 活动总数
    numberOfActivities = models.IntegerField(default=0)
    # 总计花费
    totalCost = models.IntegerField(default=0)
