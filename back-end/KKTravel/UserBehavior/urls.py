from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from UserBehavior import views

urlpatterns = [
    path('user/behavior/', views.UserBehaviorGlobalManager.as_view()),
    path('user/<int:pk>/', views.UserBehaviorSingleManager.as_view()),
]
