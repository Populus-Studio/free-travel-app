from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from TripService import views

urlpatterns = [
    path('trip/', views.TripGlobalManager.as_view()),
    path('trip/new/',views.TripSmartGenerate.as_view()),
    path('trip/me/', views.TripForUserManager.as_view()),
    path('trip/<int:pk>/', views.TripSingleManager.as_view()),
    path('trip/favor/<int:pk>/', views.TripFavorManager.as_view())
]