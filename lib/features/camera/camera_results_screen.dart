import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/data/models/care_symbol.dart';
import '../../widgets/molecules/symbol_list.dart';

class CameraResultsScreen extends ConsumerWidget {
  final List<String> symbols;

  const CameraResultsScreen({
    super.key,
    required this.symbols,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    
    // Get care symbols from the detected IDs
    final careSymbols = symbols
        .map((id) => contentService.getCareSymbolById(id))
        .where((symbol) => symbol != null)
        .cast<CareSymbol>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Symbols'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.go('/camera'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryTeal,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Symbols Detected',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${careSymbols.length} care symbols found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: careSymbols.isEmpty
                ? _buildNoSymbolsFound(context)
                : SymbolList(symbols: careSymbols),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSymbolsFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No symbols detected',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try scanning a different care label or check the lighting',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/camera'),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
