# How to Upload Stain Solutions to Firestore

## The Problem

The original `dart run lib/scripts/upload_stain_solutions.dart` approach doesn't work because:
- `cloud_firestore` and `firebase_core` are **Flutter plugins** that require the Flutter engine and platform channels
- They cannot run in a standalone Dart VM (`dart run`)
- Direct REST API calls require authentication (403 Permission Denied)

## ✅ Solution: Use Flutter App UI

Since your app already has Firebase configured, the easiest way is to use a Flutter UI that runs the upload.

### Step 1: Copy the Data File

Make sure `stain_solutions.jsonl` is accessible:

**Option A:** Add to assets (recommended for permanent setup)
```yaml
# In pubspec.yaml, under flutter: > assets:
assets:
  - Content/stain_solutions.jsonl
```

**Option B:** Just keep it in `Content/` folder and run from project root

### Step 2: Add Route to Your App

In your main app file or router, add access to the admin screen:

```dart
import 'package:washed_clean/features/admin_upload_screen.dart';

// In your app's navigation/routing:
// Add a way to navigate to AdminUploadScreen()

// Example with a button:
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminUploadScreen()),
    );
  },
  child: const Text('Admin Upload'),
)
```

### Step 3: Run Your App

```bash
# On Android emulator or device:
flutter run

# Or on web:
flutter run -d chrome
```

### Step 4: Navigate to Admin Screen & Upload

1. Open the app
2. Navigate to the Admin Upload screen
3. Tap "Start Upload"
4. Wait for completion (you'll see progress for each document)

### Step 5: Remove Admin Screen (Optional)

After uploading, you can:
- Delete `lib/features/admin_upload_screen.dart`
- Remove the route from your app
- Or keep it for future data management

## Alternative: Use Firebase Console (Manual)

If you prefer not to create UI:

1. Convert JSONL to Firestore Import format
2. Use Firebase Console > Firestore > Import/Export feature
3. Or use Firebase CLI with proper authentication

## Alternative: Python Script with Firebase Admin SDK

If you have Python installed:

```python
import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase Admin
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# Read and upload
with open('Content/stain_solutions.jsonl', 'r') as f:
    for line in f:
        data = json.loads(line)
        doc_id = data['title'].lower().replace(' ', '_')
        db.collection('stain_solutions').document(doc_id).set(data)
```

You'll need to download a service account key from Firebase Console > Project Settings > Service Accounts.

## Why This Happened

Flutter plugins like `cloud_firestore` use platform channels to communicate with native code:
- On Android: Kotlin/Java Firebase SDK
- On iOS: Swift/Objective-C Firebase SDK  
- On Web: Firebase JS SDK

The standalone Dart VM doesn't have these platform implementations, so `dart run` fails.

## Summary

**Recommended approach:** Use the Flutter UI (`AdminUploadScreen`)  
**Why:** It's the easiest, uses your existing Firebase setup, and provides visual feedback.



