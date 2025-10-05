import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/services/content_service.dart';
import 'core/services/search_service.dart';
import 'core/services/favorites_service.dart';
import 'core/services/ratings_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/symbol_service.dart';

class WashedCleanApp extends ConsumerStatefulWidget {
  const WashedCleanApp({super.key});

  @override
  ConsumerState<WashedCleanApp> createState() => _WashedCleanAppState();
}

class _WashedCleanAppState extends ConsumerState<WashedCleanApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize services
    ref.read(contentServiceProvider);
    ref.read(searchServiceProvider);
    ref.read(favoritesServiceProvider);
    ref.read(ratingsServiceProvider);
    ref.read(authServiceProvider);
    ref.read(symbolServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
