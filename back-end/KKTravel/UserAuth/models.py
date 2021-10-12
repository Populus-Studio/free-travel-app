from django.contrib.auth.models import AbstractUser
from django.db import models


class UserModel(AbstractUser):
    username = models.CharField(max_length=24, verbose_name="用户名", unique=True)
    openid = models.CharField(max_length=28, verbose_name="微信openid", null=True, unique=True)
    phoneNumber = models.CharField(max_length=11, verbose_name="手机号", null=True, unique=True)
    avatar = models.URLField(verbose_name="头像", default='http://dummyimage.com/300x300')

    class Meta:
        db_table = 'user'
