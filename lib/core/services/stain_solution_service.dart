import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../data/models/stain_solution.dart';
import 'firestore_service.dart';

final stainSolutionServiceProvider = Provider<StainSolutionService>((ref) {
  return StainSolutionService(ref.watch(firestoreServiceProvider));
});

final stainSolutionsProvider = FutureProvider<List<StainSolution>>((ref) async {
  final service = ref.watch(stainSolutionServiceProvider);
  return await service.getStainSolutions();
});

final stainSolutionByIdProvider = FutureProvider.family<StainSolution?, String>((ref, id) async {
  final service = ref.watch(stainSolutionServiceProvider);
  return await service.getStainSolutionById(id);
});

final stainSolutionByTitleProvider = FutureProvider.family<StainSolution?, String>((ref, title) async {
  final service = ref.watch(stainSolutionServiceProvider);
  return await service.getStainSolutionByTitle(title);
});

class StainSolutionService {
  StainSolutionService(this._firestoreService);

  final FirestoreService _firestoreService;
  List<StainSolution> _cachedSolutions = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _cachedSolutions = await _firestoreService.getStainSolutions();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing stain solutions: $e');
    }
  }

  Future<List<StainSolution>> getStainSolutions() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _cachedSolutions;
  }

  Future<StainSolution?> getStainSolutionById(String id) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      return _cachedSolutions.firstWhere((solution) => solution.id == id);
    } catch (e) {
      // If not found in cache, try Firestore
      return await _firestoreService.getStainSolutionById(id);
    }
  }

  Future<StainSolution?> getStainSolutionByTitle(String title) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      return _cachedSolutions.firstWhere(
        (solution) => solution.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (e) {
      // If not found in cache, try Firestore
      return await _firestoreService.getStainSolutionByTitle(title);
    }
  }

  List<StainSolution> searchSolutions(String query) {
    final lowerQuery = query.toLowerCase();
    return _cachedSolutions.where((solution) {
      return solution.title.toLowerCase().contains(lowerQuery) ||
          solution.introNotes.any((note) => note.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<void> refresh() async {
    _cachedSolutions = await _firestoreService.getStainSolutions();
  }
}

