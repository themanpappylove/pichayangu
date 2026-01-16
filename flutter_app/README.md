# Picha Yangu — Flutter Mobile App

Comprehensive Flutter app for Picha Yangu media management platform. Fully synced with Django backend APIs.

## Features

- **Authentication**: JWT-based login/register with token management
- **Client Management**: Create and browse clients
- **Project Management**: Organize projects per client
- **Media Gallery**: Upload, browse, and manage photos/videos
- **Versioning**: Track and manage file versions
- **Sharing**: Create secure share links with expiry and permissions
- **Recovery Vault**: Soft-deleted files with restore option
- **Duplicate Detection**: Find exact duplicate files
- **File Details**: View metadata, versions, shares, and duplicates in one place
- **Offline Support**: Queue uploads for later sync

## Architecture

- **models/models.dart** — Data models (Client, Project, MediaFile, ShareLink, etc.)
- **services/api_service.dart** — Comprehensive API client with all CRUD operations
- **screens/** — Full screen set for all app features

## API Endpoints Used

Auth:
- `POST /api/auth/login/` — JWT login
- `POST /api/auth/register/` — User registration
- `GET /api/auth/me/` — Current user

Clients & Projects:
- `GET /api/clients/` — List clients
- `POST /api/clients/` — Create client
- `GET /api/projects/` — List projects
- `POST /api/projects/` — Create project

Media:
- `GET /api/media/` — List media (non-deleted)
- `GET /api/media/{id}/` — File details
- `POST /api/media/` — Upload file
- `DELETE /api/media/{id}/` — Soft-delete
- `POST /api/media/{id}/restore/` — Restore from Recovery Vault

Versioning:
- `GET /api/media/{id}/versions/` — List versions
- `POST /api/media/{id}/create_version/` — Upload version

Sharing:
- `GET /api/media/{id}/shares/` — List share links
- `POST /api/media/{id}/create_share/` — Create share link
- `DELETE /api/shares/{id}/` — Delete share link

Duplicates & Recovery:
- `GET /api/media/{id}/duplicates/` — Find duplicates
- `GET /api/deleted/` — List deleted files

## Quick Start

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:8000
```

## Navigation

- **Login** → Authenticate with username/password
- **Home** → Dashboard, quick links
- **Clients** → Browse and create clients
- **Projects** → View/create projects per client
- **Media** → Gallery view, upload, manage
- **File Details** → Versions, shares, duplicates, metadata
- **Recovery Vault** → Restore deleted files

## Sync with Django

All app screens and API calls fully integrate with the Django backend:
- Real-time CRUD operations via REST API
- JWT authentication with token refresh
- File upload/download handling
- Soft-delete recovery with expiry tracking
- Complete versioning and sharing workflows

## Requirements

- Flutter 2.18+
- image_picker (gallery/camera access)
- http (API calls)
- shared_preferences (local token storage)
- intl (date formatting)


