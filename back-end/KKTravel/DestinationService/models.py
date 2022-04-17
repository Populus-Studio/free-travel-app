from django.db import models

# 目的地数据模型
from UserAuth.models import UserModel


class DestinationModel(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True)
    parent = models.IntegerField(default=0)


# 地点数据模型
class LocationModel(models.Model):
    name = models.CharField(max_length=200)
    # 暂时使用字符串来存储多个标签
    label = models.TextField(blank=True)
    type = models.CharField(max_length=50)
    destination = models.ForeignKey(DestinationModel, related_name="destination", on_delete=models.CASCADE)
    address = models.TextField()
    description = models.TextField(blank=True)
    cost = models.IntegerField(default=0)
    # 用整数表示时间，单位是”分钟“
    timeCost = models.IntegerField(default=0)
    rate = models.FloatField(default=0.0)
    heat = models.IntegerField(default=0)
    opentime = models.CharField(max_length=200, blank=True)
    img_url = models.URLField(blank=True)


# 记录用户和收藏的地点
class LocationFavorModel(models.Model):
    user = models.ForeignKey(UserModel, related_name="locationFavor_user", on_delete=models.CASCADE)
    site = models.ForeignKey(LocationModel, related_name="locationFavor_location", on_delete=models.CASCADE)
