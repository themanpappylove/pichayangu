from celery import shared_task
from django.utils import timezone
from .models import DeletedFile, MediaFile


@shared_task
def cleanup_expired_deleted_files():
    """Permanently delete expired DeletedFile entries and remove underlying files."""
    now = timezone.now()
    expired = DeletedFile.objects.filter(expiry__lte=now)
    deleted_count = 0
    for entry in expired:
        media = entry.media
        # delete file from storage
        try:
            storage = media.file.storage
            if media.file.name and storage.exists(media.file.name):
                storage.delete(media.file.name)
        except Exception:
            pass
        # delete media row (cascades to DeletedFile)
        media.delete()
        deleted_count += 1
    return {'deleted': deleted_count}
