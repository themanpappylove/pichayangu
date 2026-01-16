from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404, render
from .models import Client, Project, MediaFile, DeletedFile, FileVersion, ShareLink
from .serializers import (ClientSerializer, ProjectSerializer, MediaFileSerializer, 
                         DeletedFileSerializer, FileVersionSerializer, ShareLinkSerializer)
from django.utils import timezone
from datetime import timedelta


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer


class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer


class MediaFileViewSet(viewsets.ModelViewSet):
    queryset = MediaFile.objects.filter(is_deleted=False)
    serializer_class = MediaFileSerializer

    def perform_create(self, serializer):
        instance = serializer.save()
        # compute file hash for duplicate detection
        instance.compute_file_hash()

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        # soft delete with default 7-day retention
        instance.soft_delete(retention_days=7)
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(detail=True, methods=['post'])
    def restore(self, request, pk=None):
        media = get_object_or_404(MediaFile, pk=pk)
        if not media.is_deleted:
            return Response({'detail': 'Not deleted'}, status=status.HTTP_400_BAD_REQUEST)
        
        media.restore()
        # cleanup DeletedFile entry
        try:
            if hasattr(media, 'deleted_entry'):
                media.deleted_entry.delete()
        except Exception:
            pass
        
        serializer = self.get_serializer(media)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def duplicates(self, request, pk=None):
        """Find exact and near-duplicate files."""
        media = self.get_object()
        exact_dupes = []
        if media.file_hash:
            exact_dupes = MediaFile.objects.filter(file_hash=media.file_hash, is_deleted=False).exclude(id=media.id)
        
        return Response({
            'file_id': media.id,
            'file_hash': media.file_hash,
            'exact_duplicates': MediaFileSerializer(exact_dupes, many=True).data,
            'note': 'Perceptual hashing for near-duplicates requires additional dependencies (imagehash, etc.)'
        })

    @action(detail=True, methods=['post'])
    def create_version(self, request, pk=None):
        """Create a new version of this media file."""
        media = self.get_object()
        if 'file' not in request.FILES:
            return Response({'detail': 'file required'}, status=status.HTTP_400_BAD_REQUEST)
        
        version_count = media.versions.count()
        version = FileVersion.objects.create(
            media=media,
            file=request.FILES['file'],
            version_number=version_count + 1,
            created_by=request.user,
            note=request.data.get('note', '')
        )
        return Response(FileVersionSerializer(version).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['get'])
    def versions(self, request, pk=None):
        """Get all versions of this media file."""
        media = self.get_object()
        versions = media.versions.all()
        return Response(FileVersionSerializer(versions, many=True).data)

    @action(detail=True, methods=['post'])
    def create_share(self, request, pk=None):
        """Create a share link for this media file."""
        media = self.get_object()
        expires_in_days = int(request.data.get('expires_in_days', 7))
        permission = request.data.get('permission', 'view')
        
        share = ShareLink.objects.create(
            media=media,
            created_by=request.user,
            permission=permission,
            expires_at=timezone.now() + timedelta(days=expires_in_days) if expires_in_days > 0 else None
        )
        return Response(ShareLinkSerializer(share).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['get'])
    def shares(self, request, pk=None):
        """Get all share links for this media file."""
        media = self.get_object()
        shares = media.share_links.all()
        return Response(ShareLinkSerializer(shares, many=True).data)


class FileVersionViewSet(viewsets.ModelViewSet):
    queryset = FileVersion.objects.all()
    serializer_class = FileVersionSerializer


class ShareLinkViewSet(viewsets.ModelViewSet):
    queryset = ShareLink.objects.all()
    serializer_class = ShareLinkSerializer

    @action(detail=False, methods=['get'])
    def public_access(self, request):
        """Public endpoint: access file by share token (no auth required)."""
        token = request.query_params.get('token')
        if not token:
            return Response({'detail': 'token required'}, status=status.HTTP_400_BAD_REQUEST)
        
        share = get_object_or_404(ShareLink, token=token)
        if not share.is_valid():
            return Response({'detail': 'link expired'}, status=status.HTTP_403_FORBIDDEN)
        
        share.record_access()
        return Response({
            'file': share.media.file.url,
            'media_type': share.media.media_type,
            'permission': share.permission,
            'created_by': str(share.created_by),
        })


class DeletedFileViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = DeletedFile.objects.all()
    serializer_class = DeletedFileSerializer


# Template views for web UI
def dashboard(request):
    clients = Client.objects.all()
    projects = Project.objects.all()
    media = MediaFile.objects.filter(is_deleted=False)
    deleted = DeletedFile.objects.all()
    
    return render(request, 'mediaapp/dashboard.html', {
        'clients_count': clients.count(),
        'projects_count': projects.count(),
        'media_count': media.count(),
        'deleted_count': deleted.count(),
        'recent_clients': clients[:3],
    })


def clients_view(request):
    clients = Client.objects.all()
    return render(request, 'mediaapp/clients.html', {'clients': clients})


def media_view(request):
    media = MediaFile.objects.filter(is_deleted=False)
    clients = Client.objects.all()
    projects = Project.objects.all()
    
    return render(request, 'mediaapp/media.html', {
        'media': media,
        'clients': clients,
        'projects': projects,
    })


def projects_view(request):
    projects = Project.objects.all()
    return render(request, 'mediaapp/projects.html', {'projects': projects})

def recovery_view(request):
    deleted_files = DeletedFile.objects.all()
    return render(request, 'mediaapp/recovery.html', {'deleted_files': deleted_files})


def file_detail_view(request, file_id):
    media = get_object_or_404(MediaFile, id=file_id)
    return render(request, 'mediaapp/file_detail.html', {'media': media})
