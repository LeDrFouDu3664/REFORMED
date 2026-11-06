from django.urls import path
from . import views

app_name = 'accueil'

urlpatterns = [
    path('', views.accueil, name='accueil'),
    path('reglement/', views.reglement, name='reglement'),
    path('boutique/', views.boutique, name='boutique'),
    path('streamers/', views.streamers, name='streamers'),
    path('vote/', views.vote, name='vote'),
    path('dashboard/', views.dashboard, name='dashboard'),
]
