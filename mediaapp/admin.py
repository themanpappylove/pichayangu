from django.contrib import admin
from .models import Client, Project, MediaFile, DeletedFile, FileVersion, ShareLink


@admin.register(Client)
class ClientAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'owner', 'created_at')


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'client', 'created_at')


@admin.register(MediaFile)
class MediaFileAdmin(admin.ModelAdmin):
    list_display = ('id', 'project', 'file', 'media_type', 'status', 'is_deleted', 'file_hash', 'created_at')


@admin.register(DeletedFile)
class DeletedFileAdmin(admin.ModelAdmin):
    list_display = ('id', 'media', 'deleted_at', 'expiry')


@admin.register(FileVersion)
class FileVersionAdmin(admin.ModelAdmin):
    list_display = ('id', 'media', 'version_number', 'created_by', 'created_at')


@admin.register(ShareLink)
class ShareLinkAdmin(admin.ModelAdmin):
    list_display = ('id', 'media', 'created_by', 'permission', 'expires_at', 'access_count', 'created_at')
