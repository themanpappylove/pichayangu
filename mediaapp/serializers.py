from rest_framework import serializers
from .models import Client, Project, MediaFile, DeletedFile, FileVersion, ShareLink


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = ['id', 'name', 'created_at']


class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = ['id', 'client', 'name', 'created_at']


class FileVersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = FileVersion
        fields = ['id', 'media', 'file', 'version_number', 'created_by', 'note', 'created_at']
        read_only_fields = ['version_number', 'created_at']


class ShareLinkSerializer(serializers.ModelSerializer):
    is_valid = serializers.SerializerMethodField()

    class Meta:
        model = ShareLink
        fields = ['id', 'media', 'token', 'created_by', 'permission', 'expires_at', 'access_count', 'is_valid', 'created_at']
        read_only_fields = ['token', 'access_count', 'created_at']

    def get_is_valid(self, obj):
        return obj.is_valid()


class MediaFileSerializer(serializers.ModelSerializer):
    versions = FileVersionSerializer(many=True, read_only=True)
    share_links = ShareLinkSerializer(many=True, read_only=True)
    duplicates = serializers.SerializerMethodField()

    class Meta:
        model = MediaFile
        fields = ['id', 'project', 'uploaded_by', 'file', 'media_type', 'status', 'is_deleted', 'file_hash', 'versions', 'share_links', 'duplicates', 'created_at']
        read_only_fields = ['is_deleted', 'file_hash', 'created_at']

    def get_duplicates(self, obj):
        """Find exact duplicates (same file_hash)."""
        if not obj.file_hash:
            return []
        duplicates = MediaFile.objects.filter(file_hash=obj.file_hash, is_deleted=False).exclude(id=obj.id)
        return [{'id': d.id, 'file': d.file.name} for d in duplicates]


class DeletedFileSerializer(serializers.ModelSerializer):
    media = MediaFileSerializer(read_only=True)

    class Meta:
        model = DeletedFile
        fields = ['id', 'media', 'deleted_at', 'expiry']
