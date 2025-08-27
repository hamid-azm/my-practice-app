from django.urls import path
from . import views

urlpatterns = [
    path('hello/', views.hello_world, name='hello'),
    path('hello-list/', views.hello_world_list, name='hello_list'),
    path('health/', views.health_check, name='health_check'),
]