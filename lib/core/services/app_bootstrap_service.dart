import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content_service.dart';
import 'favorites_service.dart';
import 'ratings_service.dart';

/// App bootstrap provider that handles all initialization
final appBootstrapProvider = FutureProvider<void>((ref) async {
  final bootstrapService = AppBootstrapService(ref);
  return bootstrapService.initialize();
});

class AppBootstrapService {
  AppBootstrapService(this._ref);
  
  final Ref _ref;

  Future<void> initialize() async {
    print('🚀 Starting app initialization...');
    
    try {
      // Initialize SharedPreferences
      await _initializeSharedPreferences();
      
      // Initialize content service (loads all JSON data)
      await _initializeContentService();
      
      // Initialize user data services
      await _initializeUserServices();
      
      print('✅ App initialization completed successfully');
    } catch (e) {
      print('❌ App initialization failed: $e');
      // Don't rethrow - let the app continue even if some services fail
      print('⚠️ Continuing with limited functionality...');
    }
  }

  Future<void> _initializeSharedPreferences() async {
    try {
      print('💾 Initializing SharedPreferences...');
      await SharedPreferences.getInstance();
      print('✅ SharedPreferences initialized');
    } catch (e) {
      print('⚠️ SharedPreferences initialization failed: $e');
    }
  }

  Future<void> _initializeContentService() async {
    try {
      print('📚 Loading content data...');
      final contentService = _ref.read(contentServiceProvider);
      await contentService.initialize();
      print('✅ Content data loaded');
    } catch (e) {
      print('⚠️ Content service initialization failed: $e');
    }
  }

  Future<void> _initializeUserServices() async {
    try {
      print('👤 Initializing user services...');
      
      // Initialize favorites service (loads from SharedPreferences)
      _ref.read(favoritesServiceProvider);
      
      // Initialize ratings service (loads from SharedPreferences)
      _ref.read(ratingsServiceProvider);
      
      print('✅ User services initialized');
    } catch (e) {
      print('⚠️ User services initialization failed: $e');
    }
  }
}
