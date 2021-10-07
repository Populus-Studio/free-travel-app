from django.contrib.auth.backends import ModelBackend
import re

from UserAuth.models import UserModel


# 自定义 登陆成功 后jwt返回的数据包
def login_return(token, user=None, request=None):
    return {
        'token': token,
        'username': user.username,
    }


def get_user_by_account(account):
    """
    根据帐号获取user对象
    :param account: 账号，可以是用户名，也可以是手机号
    :return: User对象 或者 None
    """
    try:
        if re.match('^1[3-9]\d{9}$', account):
            # 帐号为手机号
            user = UserModel.objects.get(phoneNumber=account)
        else:
            # 帐号为用户名
            user = UserModel.objects.get(username=account)
    except UserModel.DoesNotExist:
        return None
    else:
        return user


# 在这里可以自定义认证后端的方式，也可以使用其他的方式，在authenticate方法里进行定义
class UsernameMobileAuthBackend(ModelBackend):

    # 传入的username可以是手机号或用户名
    # 自定义用户名或手机号认证，如果认证没通过，默认返回None
    def authenticate(self, request, username=None, password=None, **kwargs):
        user = get_user_by_account(username)
        if user is not None and user.check_password(password):
            return user
