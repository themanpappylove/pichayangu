# Picha Yangu: Media Management for Creators

## 📸 Vision
**Picha Yangu** (Swahili for "My Picture") is a specialized media management ecosystem designed for photographers and videographers. It bridges the gap between raw storage and client delivery, ensuring every project is organized, secure, and easily accessible.

---

## 🚀 Key Features

### 1. Client-Centric Organization
*   **Hierarchical Structure**: Organize media by Client > Project > Media Files.
*   **Metadata Tagging**: Automatically tag files based on shoot date, location, or equipment.

### 2. Smart Media Vault
*   **Dual-Platform Experience**: 
    *   **Web Dashboard (Django + Bootstrap)**: For heavy-duty management, bulk uploads, and client coordination.
    *   **Mobile App (Flutter)**: For on-the-go browsing, instant previews, and sharing links with clients during shoots.
*   **Version Control**: Track "Raw," "Edited," and "Final" versions of the same file.

### 3. Safety Net: Recovery Vault
*   **Soft-Delete**: Accidentally deleted a file? It stays in the Recovery Vault for a configurable retention period (default 60 days).
*   **Instant Restoration**: Recover files to their original project with a single click before the expiry date.

### 4. Professional Delivery
*   **Secure Share Links**: Generate unique, expiring links for clients to view or download their media.
*   **Duplicate Detection**: Uses SHA256 hashing to prevent redundant uploads and save storage.

---

## 🛠 Tech Stack
*   **Backend**: Django REST Framework (Python)
*   **Frontend**: Modern Bootstrap 5 + Inter Typeface (Responsive Web)
*   **Mobile**: Flutter (Cross-platform iOS/Android)
*   **Database**: PostgreSQL (Production) / SQLite (Development)
*   **Storage**: Local Media Storage / AWS S3 Integration
*   **Async Tasks**: Celery + Redis for cleanup jobs and file processing.

---

## 💡 Future Enhancement Ideas
1.  **AI Image Tagging**: Use computer vision to automatically categorize photos (e.g., "Portrait," "Landscape," "Wedding").
2.  **In-App Proofing**: Allow clients to "favorite" or comment on specific photos directly in the share link.
3.  **Watermarking**: Automatically apply customizable watermarks to "Raw" and "Edited" previews.
4.  **Portfolio Generator**: One-click to turn a project folder into a beautiful public portfolio page.
5.  **Payment Integration**: Lock "Final" downloads until the client has paid the remaining balance.

---

## 📂 Project Structure
```text
/
├── picha_yangu/          # Core Django Settings & Configuration
├── mediaapp/             # Main Application Logic (API, Views, Models)
├── flutter_app/          # Mobile Application Source Code
├── templates/            # Modern Responsive Web Templates
├── media/                # Managed Storage (Uploads, Versions)
└── openapi.yaml          # Standardized API Documentation
```
