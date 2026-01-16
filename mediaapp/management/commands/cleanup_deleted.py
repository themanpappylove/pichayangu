from django.core.management.base import BaseCommand
from django.utils import timezone
from mediaapp.models import DeletedFile


class Command(BaseCommand):
    help = 'Permanently delete expired DeletedFile entries and remove files from storage.'

    def handle(self, *args, **options):
        now = timezone.now()
        expired = DeletedFile.objects.filter(expiry__lte=now)
        count = 0
        for entry in expired:
            media = entry.media
            try:
                storage = media.file.storage
                if media.file.name and storage.exists(media.file.name):
                    storage.delete(media.file.name)
            except Exception as e:
                self.stdout.write(self.style.WARNING(f'Failed to delete file: {e}'))
            media.delete()
            count += 1
        self.stdout.write(self.style.SUCCESS(f'Permanently deleted {count} expired media files.'))
