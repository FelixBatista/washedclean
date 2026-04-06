# Upload Stain Solutions with Python

## Setup (One-time)

### 1. Install Python Requirements

```bash
pip install firebase-admin
```

Or:

```bash
pip install -r requirements.txt
```

### 2. Setup Firebase Authentication

**Option A: Use Google Cloud CLI (Easiest)**

```bash
gcloud auth application-default login
```

This will open a browser for you to authenticate with your Google account.

**Option B: Use Service Account Key**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `washedclean-2a45d`
3. Go to **Project Settings** (gear icon) → **Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file as `serviceAccountKey.json` in your project root
6. Update the Python script to use it:

```python
# In upload_stain_solutions.py, replace the ApplicationDefault() line with:
cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
```

## Run the Upload

```bash
python upload_stain_solutions.py
```

That's it! You'll see progress for each document uploaded.

## What It Does

- Reads `Content/stain_solutions.jsonl`
- Uploads each stain solution to Firestore
- Creates document IDs from titles (e.g., "Wine" → "wine")
- Shows progress and summary

## Troubleshooting

### Error: "Default credentials not found"

Run:
```bash
gcloud auth application-default login
```

Or use a service account key (see Option B above).

### Error: "Module not found: firebase_admin"

Install the package:
```bash
pip install firebase-admin
```

### Error: "File not found: Content/stain_solutions.jsonl"

Make sure you're running the script from the project root directory where the `Content/` folder exists.

## Why Python Works

Unlike Dart's Flutter plugins, Python's Firebase Admin SDK:
- ✅ Runs standalone (no Flutter engine needed)
- ✅ Has built-in authentication
- ✅ Is designed for server-side/admin operations
- ✅ Much simpler to set up and run

This is the official way to do bulk operations on Firebase!



