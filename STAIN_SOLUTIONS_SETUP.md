# Stain Solutions Implementation Guide

## Overview

This guide explains how to use the stain solutions feature that integrates detailed stain removal instructions from Firebase Firestore into your WashedClean app.

## Features Implemented

### 1. Data Model (`StainSolution`)
- **Location**: `lib/core/data/models/stain_solution.dart`
- **Structure**: Matches the JSONL data format with:
  - Title and intro notes
  - Multiple sections (Washable Fabrics, Carpet, Upholstery, etc.)
  - Methods with materials, steps, notes, and cautions
  - Source URLs for attribution

### 2. Firestore Service
- **Location**: `lib/core/services/firestore_service.dart`
- **Methods Added**:
  - `getStainSolutions()` - Fetch all solutions
  - `getStainSolutionById(id)` - Fetch by document ID
  - `getStainSolutionByTitle(title)` - Fetch by stain name
  - `addStainSolution()` - Add new solution
  - `updateStainSolution()` - Update existing solution
  - `deleteStainSolution()` - Delete solution
  - `watchStainSolutions()` - Real-time updates stream

### 3. Stain Solution Service
- **Location**: `lib/core/services/stain_solution_service.dart`
- **Features**:
  - Caching for better performance
  - Providers for easy integration with Riverpod
  - Search functionality
  - Automatic initialization

### 4. UI Integration
- **Location**: `lib/features/stain/stain_screen.dart`
- **Features**:
  - Automatically loads detailed solutions from Firebase
  - Beautiful expandable sections by material type (Carpet, Upholstery, etc.)
  - Step-by-step instructions with numbered steps
  - Material lists
  - Important notes and cautions with warning indicators
  - Fallback to existing stain data if Firebase solution not found

## Setup Instructions

### Step 1: Upload Data to Firestore

You have the stain solutions data in `Content/stain_solutions.jsonl`. Upload it to Firestore:

```bash
# Run the upload script
dart run lib/scripts/upload_stain_solutions.dart
```

This will:
- Read all stain solutions from the JSONL file
- Upload each one to Firestore collection `stain_solutions`
- Create URL-safe document IDs based on stain titles
- Show progress and summary

### Step 2: Verify Data in Firebase Console

1. Open your Firebase Console
2. Go to Firestore Database
3. Look for the `stain_solutions` collection
4. You should see ~227 documents (one for each stain type)

### Step 3: Test the Feature

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Navigate to any stain detail screen

3. You should see:
   - Basic stain information at the top
   - Fabric-specific instructions (existing feature)
   - **NEW**: "Detailed Removal Guide" section with:
     - Important notes
     - Cautions (if any)
     - Expandable sections by material type
     - Step-by-step instructions
     - Materials needed lists

## Data Structure in Firestore

Each document in the `stain_solutions` collection has this structure:

```javascript
{
  "id": "mustard",
  "title": "Mustard",
  "intro_notes": [
    "Treat stains as soon as possible...",
    "All stain removal methods should be applied prior to laundering..."
  ],
  "sections": [
    {
      "section_name": "Washable Fabrics",
      "methods": [
        {
          "materials": [],
          "steps": [],
          "notes": ["What you will need...", "Steps to Clean..."],
          "cautions": [],
          "extra": ""
        }
      ]
    },
    {
      "section_name": "Carpet",
      "methods": [...]
    }
  ],
  "cautions": [],
  "extra": [],
  "source_archive_url": "https://web.archive.org/...",
  "source_original_url": "https://web.extension.illinois.edu/..."
}
```

## How It Works

### 1. Data Loading

When a user opens a stain detail screen:

```dart
// The stain solution is loaded by matching the stain title
final stainSolutionAsync = ref.watch(
  stainSolutionByTitleProvider(stain.name)
);
```

### 2. Caching

The `StainSolutionService` caches all solutions on first load:
- First request: Fetches all from Firestore
- Subsequent requests: Uses cached data
- Call `refresh()` to reload from Firestore

### 3. UI Rendering

The detailed solutions are displayed using:
- `_buildDetailedSolution()` - Main container
- `_buildSolutionSection()` - Each material type (expandable)
- `_buildMethod()` - Individual cleaning methods with steps

## Customization

### Change Collection Name

If you want to use a different collection name:

1. Update `firestore_service.dart`:
   ```dart
   final snapshot = await _firestore.collection('your_collection_name').get();
   ```

2. Update the upload script accordingly

### Modify UI Layout

Edit `lib/features/stain/stain_screen.dart`:
- Adjust colors, spacing, or layout in `_buildDetailedSolution()`
- Change icons or styling in `_buildSolutionSection()`
- Customize step numbering or formatting in `_buildMethod()`

### Add Search/Filtering

Use the `StainSolutionService.searchSolutions()` method:

```dart
final service = ref.read(stainSolutionServiceProvider);
final results = service.searchSolutions('wine');
```

## Troubleshooting

### "Collection not found" Error

**Solution**: Make sure you've uploaded the data using the upload script.

### Solutions Not Appearing

**Possible causes**:
1. Stain title in local data doesn't match Firestore document title
2. Firebase not initialized properly
3. Internet connection issues

**Debug**:
```dart
// Check what's being searched
print('Searching for: ${stain.name}');

// Check provider state
stainSolutionAsync.when(
  data: (solution) => print('Found: ${solution?.title}'),
  loading: () => print('Loading...'),
  error: (error, stack) => print('Error: $error'),
);
```

### Slow Loading

**Solutions**:
1. The first load fetches all solutions - this is normal
2. Subsequent loads use cache
3. Consider adding a loading indicator
4. Use `watchStainSolutions()` for real-time updates

## Benefits

1. **Comprehensive Information**: Users get detailed, step-by-step removal instructions
2. **Multiple Material Types**: Different methods for fabrics, carpets, upholstery, etc.
3. **Safety First**: Prominent display of cautions and warnings
4. **Offline Support**: Cached data works without internet
5. **Scalable**: Easy to add/update stain solutions via Firebase Console
6. **Beautiful UI**: Expandable sections, numbered steps, color-coded warnings

## Future Enhancements

Consider adding:
1. **User Contributions**: Allow users to submit their own solutions
2. **Ratings**: Let users rate the effectiveness of methods
3. **Images**: Add before/after images or instructional photos
4. **Videos**: Link to video tutorials
5. **Language Support**: Translate solutions to multiple languages
6. **Favorites**: Bookmark favorite removal methods
7. **Sharing**: Share solutions via social media

## Support

For questions or issues:
1. Check the [Flutter Firebase documentation](https://firebase.flutter.dev/)
2. Review the [Riverpod documentation](https://riverpod.dev/)
3. Check Firebase Console for data structure
4. Enable Firebase debug mode in your app

---

**Note**: The stain solutions data comes from web.extension.illinois.edu via archive.org. Ensure you comply with any attribution or licensing requirements when using this data in production.

