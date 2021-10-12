# Generated by Django 3.2.5 on 2021-10-12 02:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('UserAuth', '0005_auto_20211012_1008'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usermodel',
            name='openid',
            field=models.CharField(blank=True, max_length=28, unique=True, verbose_name='微信openid'),
        ),
        migrations.AlterField(
            model_name='usermodel',
            name='phoneNumber',
            field=models.CharField(blank=True, max_length=11, unique=True, verbose_name='手机号'),
        ),
    ]