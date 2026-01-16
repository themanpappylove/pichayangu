from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (ClientViewSet, ProjectViewSet, MediaFileViewSet, DeletedFileViewSet, 
                    FileVersionViewSet, ShareLinkViewSet,
                    landing_page, signup_view, dashboard, clients_view, projects_view, media_view, recovery_view, file_detail_view)
from .auth_views import AuthViewSet

router = DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'clients', ClientViewSet)
router.register(r'projects', ProjectViewSet)
router.register(r'media', MediaFileViewSet)
router.register(r'versions', FileVersionViewSet)
router.register(r'shares', ShareLinkViewSet)
router.register(r'deleted', DeletedFileViewSet, basename='deleted')

urlpatterns = [
    path('api/', include(router.urls)),
    path('', landing_page, name='landing'),
    path('signup/', signup_view, name='signup'),
    path('dashboard/', dashboard, name='dashboard'),
    path('clients/', clients_view, name='clients'),
    path('projects/', projects_view, name='projects'),
    path('media/', media_view, name='media'),
    path('media/<int:file_id>/', file_detail_view, name='file_detail'),
    path('recovery/', recovery_view, name='recovery'),
]
