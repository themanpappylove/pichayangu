from django.core.management.base import BaseCommand
from mediaapp.models import MediaFile
from django.db.models import Count, Q


class Command(BaseCommand):
    help = 'Scan for duplicate media files by hash.'

    def handle(self, *args, **options):
        # Find exact duplicates (same file_hash)
        dupes = MediaFile.objects.filter(is_deleted=False).values('file_hash').annotate(
            count=Count('id')
        ).filter(count__gt=1, file_hash__isnull=False)
        
        total_duplicates = 0
        for dupe in dupes:
            files = MediaFile.objects.filter(file_hash=dupe['file_hash'], is_deleted=False)
            self.stdout.write(f"\nDuplicate group (hash: {dupe['file_hash'][:16]}...):")
            for f in files:
                self.stdout.write(f"  - {f.id}: {f.file.name}")
            total_duplicates += files.count() - 1
        
        self.stdout.write(self.style.SUCCESS(f'\nFound {total_duplicates} duplicate files.'))
        self.stdout.write(self.style.WARNING('Tip: Use /api/media/{id}/duplicates/ endpoint to find dupes for a specific file.'))
