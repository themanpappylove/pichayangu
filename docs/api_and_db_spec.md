# Picha Yangu — API & DB Schema

This document contains the OpenAPI specification and the database schema for the initial Picha Yangu MVP.

Files added:
- OpenAPI spec: [openapi.yaml](openapi.yaml)

## API Summary

- Base path: `/api/`
- Resources: `clients`, `projects`, `media`, `deleted`
- Key behaviors:
  - `media` DELETE: performs a soft-delete (moves the file to the Recovery Vault)
  - `media` restore: POST `/api/media/{id}/restore/` to restore a soft-deleted file

See the full machine-readable OpenAPI at [openapi.yaml](openapi.yaml).

## Database Schema (models)

1. `auth_user` (Django's default `User`)

2. `mediaapp_client`
- `id` (PK, integer)
- `owner_id` (FK -> auth_user.id)
- `name` (string)
- `created_at` (datetime)

3. `mediaapp_project`
- `id` (PK)
- `client_id` (FK -> mediaapp_client.id)
- `name` (string)
- `created_at` (datetime)

4. `mediaapp_mediafile`
- `id` (PK)
- `project_id` (FK -> mediaapp_project.id)
- `uploaded_by_id` (FK -> auth_user.id, nullable)
- `file` (string path)
- `media_type` (enum: image|video)
- `status` (enum: raw|edited|final)
- `is_deleted` (boolean)
- `deleted_at` (datetime, nullable)
- `created_at` (datetime)

Notes:
- `is_deleted` + `deleted_at` implement soft-delete. When a media file is soft-deleted, a `mediaapp_deletedfile` entry is created containing an expiry timestamp (soft retention period).

5. `mediaapp_deletedfile`
- `id` (PK)
- `media_id` (OneToOne FK -> mediaapp_mediafile.id)
- `deleted_at` (datetime)
- `expiry` (datetime)

## Recovery Vault behavior

- Soft deletion: calling DELETE on `/api/media/{id}/` sets `is_deleted=true` and `deleted_at=now`, and creates a `DeletedFile` row with `expiry = deleted_at + retention_days`.
- Restore: POST `/api/media/{id}/restore/` toggles `is_deleted=false` and removes the `DeletedFile` record.
- Expiry/cleanup: a background job (Celery) should periodically remove expired `DeletedFile` rows and permanently delete file objects from storage.

## Recommended indices

- `mediaapp_mediafile`: index on `project_id`, `is_deleted`, and `deleted_at`.
- `mediaapp_project`: index on `client_id`.

## Next steps

- Implement migrations (`python manage.py makemigrations && migrate`).
- Add Celery periodic task for expired-deletion.
- Implement S3/Cloud storage backend and storage cleanup.
