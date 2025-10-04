import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final favoritesServiceProvider = StateNotifierProvider<FavoritesService, Set<String>>((ref) {
  return FavoritesService();
});

class FavoritesService extends StateNotifier<Set<String>> {
  static const String _key = 'favorites';

  FavoritesService() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_key);
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
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(state.toList());
      await prefs.setString(_key, favoritesJson);
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
