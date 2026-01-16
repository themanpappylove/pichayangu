# Picha Yangu (minimal scaffold)

This repository contains a minimal Django + DRF scaffold for Picha Yangu — a media management app for photographers/videographers.

Quick start (development):

1. Create a Python virtualenv and install requirements:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Run migrations and start the dev server:

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser  # optional
python manage.py runserver
```

3. Run cleanup job manually or via cron/Celery beat:

```bash
# manual
python manage.py cleanup_deleted

# with Celery worker (requires Redis)
celery -A picha_yangu worker -l info
# in another shell run periodic tasks (requires celery beat configured)
celery -A picha_yangu beat -l info
```

Notes:
- Files are stored in `media/` in development. To use S3 set environment variables `USE_S3=1` and the AWS_* settings.
- API endpoints are under `/api/` (see `openapi.yaml`).
# pichayangu