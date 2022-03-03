from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from TripService import views

urlpatterns = [
    path('trip/', views.TripGlobalManager.as_view()),
    path('trip/<int:pk>/', views.TripSingleManager.as_view())
]