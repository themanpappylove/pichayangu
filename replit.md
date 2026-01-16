# Picha Yangu

## Overview
Picha Yangu is a media management application for photographers and videographers built with Django REST Framework.

## Project Architecture
- **Backend**: Django 5.x with Django REST Framework
- **Database**: SQLite (development), can use PostgreSQL in production
- **Authentication**: JWT tokens via djangorestframework-simplejwt
- **File Storage**: Local media folder (optional S3 support via django-storages)
- **Background Tasks**: Celery with Redis (optional)

## Project Structure
```
/
├── picha_yangu/          # Django project settings
│   ├── settings.py       # Main configuration
│   ├── urls.py           # URL routing
│   ├── wsgi.py           # WSGI entry point
│   └── celery.py         # Celery configuration
├── mediaapp/             # Main application
│   ├── models.py         # Data models (Client, Project, MediaFile, etc.)
│   ├── views.py          # API views
│   ├── serializers.py    # DRF serializers
│   ├── urls.py           # App URL patterns
│   └── auth_views.py     # Authentication endpoints
├── templates/            # HTML templates
├── flutter_app/          # Flutter mobile app (placeholder)
├── manage.py             # Django management script
└── requirements.txt      # Python dependencies
```

## Key Models
- **Client**: Photographer's clients
- **Project**: Media projects for clients
- **MediaFile**: Image/video files with soft-delete capability
- **FileVersion**: Version tracking for media files
- **ShareLink**: Secure sharing links with permissions

## API Endpoints
- `/api/` - Main API routes (see openapi.yaml)
- `/admin/` - Django admin interface

## Environment Variables
- `DJANGO_SECRET`: Django secret key (defaults to 'change-me-in-prod')
- `CELERY_BROKER_URL`: Redis URL for Celery (optional)
- `USE_S3`: Set to '1' to enable S3 storage
- `AWS_*`: AWS credentials for S3 storage (when USE_S3=1)

## Development
The Django development server runs on port 5000.

## Recent Changes
- 2026-01-16: Initial Replit setup, fixed migration issue with lambda default in ShareLink model
