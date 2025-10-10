# 🎛️ Admin Panel Setup Guide

## Overview
Your Flutter app now uses Firebase Firestore for data management, making it easy for non-technical users to add, edit, and manage content through a web interface.

## 🚀 Quick Start

### 1. Access Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `washedclean-2a45d`
3. Click on "Firestore Database" in the left sidebar

### 2. Populate Initial Data
Run the population script to add sample data:

```bash
# In your project directory
dart run lib/scripts/populate_firestore.dart
```

This will add:
- 3 sample stains (Wine, Coffee, Grease)
- 2 sample fabrics (Cotton, Polyester)  
- 2 sample products (Stain Remover Spray, White Wine)
- All care symbols from your existing data

## 📊 Database Structure

### Collections Overview

#### `stains` Collection
Each document represents a stain type:
```json
{
  "id": "wine_stain",
  "name": "Wine Stain",
  "urgency": "high",
  "summary": "Red wine stains are common and challenging to remove",
  "by_fabric": [
    {
      "fabric_id": "cotton",
      "steps_md": "## How to Remove Wine Stains...",
      "recommended_products": ["stain_remover_spray"],
      "tips_md": "Act quickly for best results!"
    }
  ],
  "related_products": ["stain_remover_spray"],
  "related_fabrics": ["cotton", "polyester"]
}
```

#### `fabrics` Collection
Each document represents a fabric type:
```json
{
  "id": "cotton",
  "name": "Cotton",
  "image": "assets/images/fabrics/cotton.jpg",
  "overview_md": "# Cotton Fabric Care...",
  "steps_md": "## How to Care for Cotton...",
  "common_stains": ["wine_stain", "coffee_stain"],
  "recommended_products": ["cotton_detergent"]
}
```

#### `products` Collection
Each document represents a cleaning product:
```json
{
  "id": "stain_remover_spray",
  "name": "Stain Remover Spray",
  "image": "assets/images/products/stain_remover.jpg",
  "subtitle": "Powerful formula for tough stains",
  "ingredients_md": "## Ingredients...",
  "how_to_use_md": "## How to Use...",
  "allergen_flags": [],
  "removes_stains": ["wine_stain", "coffee_stain"],
  "fits_fabrics": ["cotton", "polyester"],
  "affiliate_url": "https://amazon.com/stain-remover-spray"
}
```

#### `care_symbols` Collection
Each document represents a laundry care symbol:
```json
{
  "id": "wash_30",
  "name": "Machine Wash, 30°C",
  "description": "Gentle wash at 30 degrees Celsius",
  "iso_code": "ISO 7000-3080",
  "category": "washing",
  "temperature": 30,
  "instructions": "Wash with cold water, gentle cycle",
  "file_name": "Waschen_30.svg"
}
```

## 🎯 How to Add Content (Non-Technical Guide)

### Adding a New Stain

1. **Go to Firestore Console**
   - Open [Firebase Console](https://console.firebase.google.com/)
   - Navigate to Firestore Database
   - Click on the `stains` collection

2. **Create New Document**
   - Click "Add document"
   - Choose "Start a collection" if it's the first item
   - Use a simple ID like `coffee_stain` or `blood_stain`

3. **Fill in the Fields**
   - `id`: Same as document ID (e.g., "coffee_stain")
   - `name`: Display name (e.g., "Coffee Stain")
   - `urgency`: "low", "medium", or "high"
   - `summary`: Brief description
   - `by_fabric`: Array of objects with fabric-specific instructions
   - `related_products`: Array of product IDs
   - `related_fabrics`: Array of fabric IDs

4. **Add Fabric-Specific Instructions**
   For the `by_fabric` field, add objects like:
   ```json
   {
     "fabric_id": "cotton",
     "steps_md": "## How to Remove Coffee Stains from Cotton\n\n1. Blot excess coffee\n2. Rinse with cold water\n3. Apply vinegar solution",
     "recommended_products": ["vinegar", "stain_remover_spray"],
     "tips_md": "Act quickly for best results!"
   }
   ```

### Adding a New Fabric

1. **Go to `fabrics` collection**
2. **Create new document** with fabric ID (e.g., "wool", "silk")
3. **Fill in fields**:
   - `id`: Fabric identifier
   - `name`: Display name
   - `image`: Path to image asset
   - `overview_md`: Markdown description
   - `steps_md`: Care instructions in markdown
   - `common_stains`: Array of stain IDs
   - `recommended_products`: Array of product IDs

### Adding a New Product

1. **Go to `products` collection**
2. **Create new document** with product ID
3. **Fill in fields**:
   - `id`: Product identifier
   - `name`: Product name
   - `image`: Path to product image
   - `subtitle`: Short description
   - `ingredients_md`: Ingredients in markdown
   - `how_to_use_md`: Usage instructions in markdown
   - `allergen_flags`: Array of allergen warnings
   - `removes_stains`: Array of stain IDs this product removes
   - `fits_fabrics`: Array of fabric IDs this product works with
   - `affiliate_url`: Amazon or store URL

## 🔧 Advanced Admin Options

### Option 1: Firebase Console (Easiest)
- **Pros**: No setup required, works immediately
- **Cons**: Basic interface, no custom validation
- **Best for**: Simple content management

### Option 2: Custom Flutter Web Admin (Recommended)
Create a simple web admin panel:

1. **Create admin web app**:
   ```bash
   flutter create admin_panel --platforms web
   cd admin_panel
   ```

2. **Add dependencies**:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     cloud_firestore: ^4.15.8
     firebase_core: ^2.24.2
   ```

3. **Build simple forms** for each collection
4. **Deploy to Firebase Hosting**

### Option 3: Third-Party Admin Tools
- **Forest Admin**: Beautiful admin interface
- **Retool**: Custom admin dashboards
- **AdminJS**: Node.js admin panel

## 📱 Real-Time Updates

Your app automatically updates when you change data in Firestore:
- **No app updates needed** for content changes
- **Instant updates** across all devices
- **Offline support** - changes sync when online

## 🛡️ Security Rules

Set up Firestore security rules to protect your data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to all collections
    match /{document=**} {
      allow read: if true;
    }
    
    // Only allow authenticated users to write
    match /{document=**} {
      allow write: if request.auth != null;
    }
  }
}
```

## 🚀 Deployment

### For Production:
1. **Set up proper security rules**
2. **Enable authentication** for admin access
3. **Use Firebase Authentication** for admin users
4. **Set up monitoring** and alerts

### For Development:
- Current setup works immediately
- No authentication required
- Perfect for testing and content management

## 📞 Support

If you need help:
1. **Firebase Documentation**: [Firestore Docs](https://firebase.google.com/docs/firestore)
2. **Flutter Firestore**: [FlutterFire Docs](https://firebase.flutter.dev/docs/firestore/overview/)
3. **This Guide**: Keep this file handy for reference

## 🎉 You're All Set!

Your app now has:
- ✅ **Real-time data updates**
- ✅ **Easy content management**
- ✅ **No technical knowledge required**
- ✅ **Scalable architecture**
- ✅ **Free tier usage**

Start adding content through the Firebase Console and watch your app update instantly! 🚀

