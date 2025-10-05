import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'content_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  final contentService = ref.watch(contentServiceProvider);
  return SearchService(contentService);
});

class SearchResult {
  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.score,
  });

  final String type;
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final double score;
}

class SearchService {
  SearchService(this._contentService);

  final ContentService _contentService;

  List<SearchResult> search(String query) {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = _normalizeQuery(query);
    final results = <SearchResult>[];

    // Search stains
    for (final stain in _contentService.stains) {
      final score = _calculateScore(normalizedQuery, stain.name, 1.3);
      if (score > 0) {
        results.add(SearchResult(
          type: 'stain',
          id: stain.id,
          title: stain.name,
          subtitle: stain.summary,
          image: '', // Stains don't have images in the model
          score: score,
        ));
      }
    }

    // Search fabrics
    for (final fabric in _contentService.fabrics) {
      final score = _calculateScore(normalizedQuery, fabric.name, 1.2);
      if (score > 0) {
        results.add(SearchResult(
          type: 'fabric',
          id: fabric.id,
          title: fabric.name,
          subtitle: 'Fabric care guide',
          image: fabric.image,
          score: score,
        ));
      }
    }

    // Search products
    for (final product in _contentService.products) {
      final score = _calculateScore(normalizedQuery, product.name, 1.1);
      if (score > 0) {
        results.add(SearchResult(
          type: 'product',
          id: product.id,
          title: product.name,
          subtitle: product.subtitle,
          image: product.image,
          score: score,
        ));
      }
    }


    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }

  String _normalizeQuery(String query) {
    return query.toLowerCase().trim();
  }

  double _calculateScore(String query, String text, double typeBoost) {
    final normalizedText = _normalizeQuery(text);
    final queryWords = query.split(' ').where((w) => w.isNotEmpty).toList();
    final textWords = normalizedText.split(' ').where((w) => w.isNotEmpty).toList();

    if (queryWords.isEmpty) return 0;

    double score = 0;
    int matches = 0;

    for (final queryWord in queryWords) {
      for (final textWord in textWords) {
        if (textWord.contains(queryWord)) {
          matches++;
          score += 1.0;
        } else if (queryWord.length >= 5 && _levenshteinDistance(queryWord, textWord) <= 1) {
          // Fuzzy matching for longer words
          matches++;
          score += 0.8;
        }
      }
    }

    if (matches == 0) return 0;

    // Normalize by query length and apply type boost
    return (score / queryWords.length) * typeBoost;
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1.length < s2.length) {
      return _levenshteinDistance(s2, s1);
    }

    if (s2.isEmpty) return s1.length;

    List<int> previousRow = List.generate(s2.length + 1, (index) => index);

    for (int i = 0; i < s1.length; i++) {
      List<int> currentRow = [i + 1];
      for (int j = 0; j < s2.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (s1[i] == s2[j] ? 0 : 1);
        currentRow.add([insertions, deletions, substitutions].reduce((a, b) => a < b ? a : b));
      }
      previousRow = currentRow;
    }

    return previousRow.last;
  }
}
