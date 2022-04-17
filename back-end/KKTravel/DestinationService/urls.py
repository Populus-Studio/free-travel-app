from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from DestinationService import views

urlpatterns = [
    path('destination/<int:pk>',views.DestinationSingleManager.as_view()),
    path('destination/search', views.DestinationListManager.as_view()),
    path('site/<int:pk>', views.LocationSingleManager.as_view()),
    path('site/search', views.LocationListManager.as_view()),
    path('destination/additions', views.DestinationMutiAdd.as_view()),
    path('site/additions', views.LocationMutiAdd.as_view()),
    path('site/favor', views.LocationFavorManager.as_view())
]