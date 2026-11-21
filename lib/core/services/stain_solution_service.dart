import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/stain_solution.dart';
import 'content_service.dart';

final stainSolutionServiceProvider = Provider<StainSolutionService>((ref) {
  return StainSolutionService(ref.watch(contentServiceProvider));
});

final stainSolutionsProvider = FutureProvider<List<StainSolution>>((ref) async {
  return ref.watch(stainSolutionServiceProvider).getStainSolutions();
});

final stainSolutionByIdProvider =
    FutureProvider.family<StainSolution?, String>((ref, id) async {
  return ref.watch(stainSolutionServiceProvider).getStainSolutionById(id);
});

final stainSolutionByTitleProvider =
    FutureProvider.family<StainSolution?, String>((ref, title) async {
  return ref.watch(stainSolutionServiceProvider).getStainSolutionByTitle(title);
});

class StainSolutionService {
  StainSolutionService(this._contentService);

  final ContentService _contentService;

  Future<void>? _initialization;
  List<StainSolution> _solutions = [];

  Future<void> _initialize() async {
    await _contentService.initialize();
    _solutions = _contentService.stainSolutions;
  }

  Future<void> _ensureInitialized() => _initialization ??= _initialize();

  Future<List<StainSolution>> getStainSolutions() async {
    await _ensureInitialized();
    return _solutions;
  }

  Future<StainSolution?> getStainSolutionById(String id) async {
    await _ensureInitialized();
    for (final solution in _solutions) {
      if (solution.id == id) return solution;
    }
    return null;
  }

  Future<StainSolution?> getStainSolutionByTitle(String title) async {
    await _ensureInitialized();
    final normalizedTitle = title.trim().toLowerCase();
    for (final solution in _solutions) {
      if (solution.title.trim().toLowerCase() == normalizedTitle) {
        return solution;
      }
    }
    return null;
  }

  List<StainSolution> searchSolutions(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _solutions;

    return _solutions.where((solution) {
      return solution.title.toLowerCase().contains(normalizedQuery) ||
          solution.introNotes.any(
            (note) => note.toLowerCase().contains(normalizedQuery),
          );
    }).toList();
  }

  Future<void> refresh() async {
    _initialization = null;
    await _ensureInitialized();
  }
}
