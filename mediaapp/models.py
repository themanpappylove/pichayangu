from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone
from datetime import timedelta
import uuid
import hashlib

User = get_user_model()


def generate_share_token():
    return str(uuid.uuid4())


class Client(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='clients')
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name}"


class Project(models.Model):
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='projects')
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.client.name} / {self.name}"


class MediaFile(models.Model):
    MEDIA_TYPES = (('image', 'Image'), ('video', 'Video'))
    STATUS_CHOICES = (('raw', 'Raw'), ('edited', 'Edited'), ('final', 'Final'))

    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='media')
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    file = models.FileField(upload_to='uploads/%Y/%m/%d')
    media_type = models.CharField(max_length=10, choices=MEDIA_TYPES)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='raw')
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    file_hash = models.CharField(max_length=64, blank=True, null=True, db_index=True)  # SHA256 for duplicate detection
    created_at = models.DateTimeField(auto_now_add=True)

    def soft_delete(self, retention_days=7):
        if self.is_deleted:
            return
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save(update_fields=['is_deleted', 'deleted_at'])
        DeletedFile.objects.create(media=self, expiry=self.deleted_at + timedelta(days=retention_days))

    def restore(self):
        if not self.is_deleted:
            return
        self.is_deleted = False
        self.deleted_at = None
        self.save(update_fields=['is_deleted', 'deleted_at'])

    def compute_file_hash(self):
        """Compute SHA256 hash of the file for duplicate detection."""
        if self.file:
            sha256_hash = hashlib.sha256()
            self.file.seek(0)
            for byte_block in iter(lambda: self.file.read(4096), b''):
                sha256_hash.update(byte_block)
            self.file_hash = sha256_hash.hexdigest()
            self.save(update_fields=['file_hash'])

    def __str__(self):
        return f"{self.project} - {self.file.name}"


class DeletedFile(models.Model):
    media = models.OneToOneField(MediaFile, on_delete=models.CASCADE, related_name='deleted_entry')
    deleted_at = models.DateTimeField(auto_now_add=True)
    expiry = models.DateTimeField()

    def is_expired(self):
        return timezone.now() >= self.expiry

    def __str__(self):
        return f"Deleted: {self.media.file.name} (expires {self.expiry})"


class FileVersion(models.Model):
    """Track multiple versions of the same logical file."""
    media = models.ForeignKey(MediaFile, on_delete=models.CASCADE, related_name='versions')
    file = models.FileField(upload_to='versions/%Y/%m/%d')
    version_number = models.IntegerField(default=1)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    note = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-version_number']

    def __str__(self):
        return f"{self.media.file.name} v{self.version_number}"


class ShareLink(models.Model):
    PERMISSION_CHOICES = (('view', 'View Only'), ('download', 'Download'))
    
    media = models.ForeignKey(MediaFile, on_delete=models.CASCADE, related_name='share_links')
    token = models.CharField(max_length=64, unique=True, default=generate_share_token)
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='shared_links')
    permission = models.CharField(max_length=10, choices=PERMISSION_CHOICES, default='view')
    expires_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    access_count = models.IntegerField(default=0)

    def is_valid(self):
        if self.expires_at and timezone.now() >= self.expires_at:
            return False
        return True

    def record_access(self):
        self.access_count += 1
        self.save(update_fields=['access_count'])

    def __str__(self):
        return f"Share: {self.media.file.name} ({self.token[:8]}...)"
