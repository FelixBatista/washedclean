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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          // Get the app initialization future
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
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchScreen(query: query);
        },
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/camera/results',
        builder: (context, state) {
          final symbols = state.extra as List<String>? ?? [];
          return CameraResultsScreen(symbols: symbols);
        },
      ),
      GoRoute(
        path: '/stain/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final fabricId = state.uri.queryParameters['fabric'];
          return StainScreen(stainId: id, fabricId: fabricId);
        },
      ),
      GoRoute(
        path: '/fabric/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FabricScreen(fabricId: id);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/symbols',
        builder: (context, state) => const SymbolsScreen(),
      ),
    ],
  );
});
