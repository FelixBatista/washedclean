import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum RatingType { up, down, none }

final ratingsServiceProvider = StateNotifierProvider<RatingsService, Map<String, RatingType>>((ref) {
  return RatingsService();
});

class RatingsService extends StateNotifier<Map<String, RatingType>> {
  static const String _key = 'ratings';

  RatingsService() : super({}) {
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = prefs.getString(_key);
      if (ratingsJson != null) {
        final Map<String, dynamic> ratingsMap = json.decode(ratingsJson);
        state = ratingsMap.map((key, value) => MapEntry(key, RatingType.values[value]));
      }
    } catch (e) {
      print('Error loading ratings: $e');
    }
  }

  Future<void> _saveRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = json.encode(state.map((key, value) => MapEntry(key, value.index)));
      await prefs.setString(_key, ratingsJson);
    } catch (e) {
      print('Error saving ratings: $e');
    }
  }

  Future<void> setRating(String itemId, RatingType rating) async {
    final newRatings = Map<String, RatingType>.from(state);
    newRatings[itemId] = rating;
    state = newRatings;
    await _saveRatings();
  }

  RatingType getRating(String itemId) {
    return state[itemId] ?? RatingType.none;
  }

  Future<void> clearRating(String itemId) async {
    final newRatings = Map<String, RatingType>.from(state);
    newRatings.remove(itemId);
    state = newRatings;
    await _saveRatings();
  }

  Future<void> clearAllRatings() async {
    state = {};
    await _saveRatings();
  }
}
