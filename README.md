# paustikpoornahar-new

Paustik Poornahar food delivery platform.

- `backend/`: Laravel admin panel, restaurant panel and REST API. Deployed on Railway from this folder (see `backend/Dockerfile`).
- `customer app/`: Flutter customer app (Android, iOS, web).

## Backend on Railway

Built from `backend/Dockerfile`. Configuration comes from Railway service variables (no `.env` in the repo).
On first boot `backend/docker/railway-init.php` imports the seed database, creates the admin from
`ADMIN_EMAIL` / `ADMIN_PASSWORD`, and copies default images into the storage volume.

## Customer app

Add your Firebase config files locally (they are not committed):
`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
