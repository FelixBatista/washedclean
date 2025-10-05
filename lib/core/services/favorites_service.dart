import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth_service.dart';

final favoritesServiceProvider = StateNotifierProvider<FavoritesService, Set<String>>((ref) {
  return FavoritesService(ref);
});

class FavoritesService extends StateNotifier<Set<String>> {
  FavoritesService(this._ref) : super({}) {
    _loadFavorites();
  }

  final Ref _ref;
  static const String _key = 'favorites';

  Future<void> _loadFavorites() async {
    try {
      final user = _ref.read(authServiceProvider);
      if (user == null) {
        state = {};
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_key}_${user.id}';
      final favoritesJson = prefs.getString(userKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        state = favoritesList.cast<String>().toSet();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final user = _ref.read(authServiceProvider);
      if (user == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_key}_${user.id}';
      final favoritesJson = json.encode(state.toList());
      await prefs.setString(userKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  Future<void> toggleFavorite(String itemId) async {
    final newFavorites = Set<String>.from(state);
    if (newFavorites.contains(itemId)) {
      newFavorites.remove(itemId);
    } else {
      newFavorites.add(itemId);
    }
    state = newFavorites;
    await _saveFavorites();
  }

  bool isFavorite(String itemId) {
    return state.contains(itemId);
  }

  Future<void> clearFavorites() async {
    state = {};
    await _saveFavorites();
  }
}
