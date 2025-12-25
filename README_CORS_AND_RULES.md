This repo includes example CORS and security rules for Firebase Storage and Firestore to support web uploads.

Files added:
- `cors.json` - example CORS configuration. Replace the `origin` with your web app origin(s) (e.g., https://yourdomain.com) before applying in production.
- `storage.rules` - recommended Firebase Storage rules allowing authenticated users to write under `users/{uid}/medical_files`.
- `firestore.rules` - recommended Firestore rules for the `users/{uid}/medical_files` subcollection.

How to apply

1) Apply CORS to your bucket (requires `gsutil` from Google Cloud SDK):

```bash
# using your project's bucket name from firebase config
gsutil cors set cors.json gs://medpass3.appspot.com
```

Alternatively on Windows you can run the provided PowerShell helper:

```powershell
# from repository root
.
\scripts\apply_cors.ps1
```

2) Deploy security rules (from Firebase CLI):

- Install and login to Firebase CLI if needed: `npm install -g firebase-tools` and `firebase login`.
- Copy `storage.rules` and `firestore.rules` into your Firebase rules config or reference them in `firebase.json`.
- Deploy rules:

```bash
firebase deploy --only storage,firestore
```

Notes
- For development on `localhost`, set the `origin` in `cors.json` to the origin shown in your browser console (e.g., http://localhost:60725). For production, use your real domain and avoid using `*` when credentials are involved.
- Ensure your Storage and Firestore rules match your app's auth model: if you use Firestore-only fallback (no FirebaseAuth), browser uploads that require authenticated requests will fail; consider signed upload URLs or Cloud Functions for unauthenticated uploads.
