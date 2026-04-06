# Integration Steps - Add Admin Upload to Your App

## Step 1: Add the Route

Open `lib/core/routing/app_router.dart` and add:

```dart
// At the top, add import:
import '../../features/admin_upload_screen.dart';

// In the routes list, add this new route (anywhere in the list):
GoRoute(
  path: '/admin/upload',
  builder: (context, state) => const AdminUploadScreen(),
),
```

## Step 2: Add a Way to Access It

**Option A: Add to Profile/Settings Screen** (Recommended)

In your `ProfileScreen` or similar, add a debug button:

```dart
// In your profile screen:
ElevatedButton(
  onPressed: () => context.go('/admin/upload'),
  child: const Text('Admin: Upload Data'),
)
```

**Option B: Direct Navigation** (Quick Test)

Modify the initial route temporarily in `app_router.dart`:

```dart
initialLocation: '/admin/upload',  // Change from '/splash'
```

## Step 3: Run & Upload

```bash
flutter run
```

Navigate to the admin screen and tap "Start Upload". You'll see real-time progress!

## Step 4: Done! 

After uploading, you can:
- Remove the route (set `initialLocation` back to `'/splash'`)
- Keep the admin screen for future data management
- Remove the button from your profile screen

---

## Full Example: app_router.dart

```dart
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/app_bootstrap_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/intro/intro_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/camera/camera_results_screen.dart';
import '../../features/stain/stain_screen.dart';
import '../../features/fabric/fabric_screen.dart';
import '../../features/product/product_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/symbols/symbols_screen.dart';
import '../../features/admin_upload_screen.dart';  // ← ADD THIS

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          final initFuture = ref.read(appBootstrapProvider.future);
          return SplashScreen(loadFuture: initFuture);
        },
      ),
      GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // ... (rest of your routes)
      
      // ← ADD THIS ROUTE
      GoRoute(
        path: '/admin/upload',
        builder: (context, state) => const AdminUploadScreen(),
      ),
    ],
  );
});
```

That's it! 🎉



