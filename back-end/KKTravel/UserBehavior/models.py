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
    contextTime = models.DateTimeField()
    contextLocation = models.TextField(blank=True)