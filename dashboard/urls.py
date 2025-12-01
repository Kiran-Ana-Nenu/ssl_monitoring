from django.urls import path
from . import views
app_name = 'dashboard'
urlpatterns = [
    path('', views.index, name='index'),
    path('domain-row/<int:domain_id>/', views.domain_row, name='domain_row'),
    path('check-now/<int:domain_id>/', views.trigger_check_now, name='trigger_check_now'),
]
