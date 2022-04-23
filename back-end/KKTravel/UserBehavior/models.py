from django.db import models
from DestinationService.models import LocationModel
from UserAuth.models import UserModel


# 用户行为模型
class UserBehaviorModel(models.Model):
    user = models.ForeignKey(UserModel, related_name="behavior_user", on_delete=models.CASCADE)
    site = models.ForeignKey(LocationModel, related_name="behavior_location", on_delete=models.CASCADE)
    behaviorType = models.IntegerField(default=0)
    behaviorBool = models.BooleanField()
    behaviorWeight = models.FloatField()
    # 记录访问时间
    contextTime = models.DateTimeField()
    # 记录对应site地点的地理坐标
    contextLocation = models.TextField(blank=True)