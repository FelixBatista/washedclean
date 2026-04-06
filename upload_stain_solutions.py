#!/usr/bin/env python3
"""
Upload stain solutions to Firestore using Firebase Admin SDK

Requirements:
    pip install firebase-admin

Usage:
    python upload_stain_solutions.py
"""

import json
import re
import firebase_admin
from firebase_admin import credentials, firestore

# Firebase project configuration
PROJECT_ID = 'washedclean-2a45d'

def create_doc_id(title):
    """Create a URL-safe document ID from title"""
    doc_id = title.lower()
    doc_id = re.sub(r'[^\w\s-]', '', doc_id)  # Remove special chars
    doc_id = re.sub(r'\s+', '_', doc_id)      # Replace spaces with underscores
    doc_id = re.sub(r'_+', '_', doc_id)       # Replace multiple underscores with single
    return doc_id.strip('_')

def main():
    print('🚀 Starting stain solutions upload to Firestore...\n')

    # Initialize Firebase Admin SDK
    # Using Application Default Credentials (works if you're logged in with gcloud)
    print('📱 Initializing Firebase...')
    try:
        # Try to use existing app or create new one
        try:
            app = firebase_admin.get_app()
        except ValueError:
            # If you have a service account key file, use this instead:
            # cred = credentials.Certificate('path/to/serviceAccountKey.json')
            # firebase_admin.initialize_app(cred)
            
            # Using Application Default Credentials
            cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(cred, {
                'projectId': PROJECT_ID,
            })
        
        print('✅ Firebase initialized\n')
    except Exception as e:
        print(f'❌ Firebase initialization failed: {e}')
        print('\nTo fix this, you need to either:')
        print('1. Run: gcloud auth application-default login')
        print('2. Or download a service account key and update the script')
        print('   (Firebase Console > Project Settings > Service Accounts)')
        return

    db = firestore.client()
    collection = db.collection('stain_solutions')

    # Read the JSONL file
    jsonl_file = 'Content/stain_solutions.jsonl'
    
    try:
        print(f'📖 Reading stain solutions from {jsonl_file}...')
        with open(jsonl_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        print(f'   Found {len(lines)} stain solutions\n')
    except FileNotFoundError:
        print(f'❌ Error: {jsonl_file} not found')
        print('   Make sure you\'re running this from the project root directory')
        return

    success_count = 0
    error_count = 0
    errors = []

    # Process each line
    for i, line in enumerate(lines, 1):
        line = line.strip()
        if not line:
            continue

        try:
            # Parse JSON
            data = json.loads(line)
            title = data.get('title', '')
            
            # Create a URL-safe ID from the title
            doc_id = create_doc_id(title)
            
            # Upload to Firestore
            collection.document(doc_id).set(data)
            
            success_count += 1
            print(f'✅ [{i}/{len(lines)}] Uploaded: {title} (ID: {doc_id})')
            
        except Exception as e:
            error_count += 1
            error_msg = f'Line {i}: {str(e)}'
            errors.append(error_msg)
            print(f'❌ [{i}/{len(lines)}] Error: {error_msg}')

    # Print summary
    print('\n' + '=' * 60)
    print('📊 Upload Summary:')
    print(f'   ✅ Successfully uploaded: {success_count}')
    print(f'   ❌ Errors: {error_count}')
    
    if errors:
        print('\n❌ Error Details:')
        for error in errors:
            print(f'   - {error}')
    
    print('=' * 60)
    print('\n🎉 Upload process completed!')

if __name__ == '__main__':
    main()



