from django.contrib.auth.models import AbstractUser
from django.db import models


class UserModel(AbstractUser):
    username = models.CharField(max_length=24, verbose_name="用户名", unique=True)
    openid = models.CharField(max_length=28, verbose_name="微信openid", default='')
    phoneNumber = models.CharField(max_length=11, verbose_name="手机号", default='')

    class Meta:
        db_table = 'user'
