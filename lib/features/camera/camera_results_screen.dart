import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/symbol_service.dart';

class CameraResultsScreen extends ConsumerWidget {
  const CameraResultsScreen({
    super.key,
    required this.symbols,
  });

  final List<String> symbols;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbolService = ref.watch(symbolServiceProvider);
    
    // Get care symbols from the detected IDs
    final careSymbols = symbols
        .map((id) => symbolService.getSymbolById(id))
        .where((symbol) => symbol != null)
        .cast<CareSymbol>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Symbols'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
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
                    color: AppTheme.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: careSymbols.isEmpty
                ? _buildNoSymbolsFound(context)
                : _buildSymbolList(context, careSymbols),
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
            const Icon(
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

  Widget _buildSymbolList(BuildContext context, List<CareSymbol> symbols) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        final symbol = symbols[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppTheme.primaryTeal,
              ),
            ),
            title: Text(
              symbol.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(symbol.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show symbol details
              _showSymbolDetails(context, symbol);
            },
          ),
        );
      },
    );
  }

  void _showSymbolDetails(BuildContext context, CareSymbol symbol) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Symbol details
                Text(
                  symbol.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  symbol.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ISO Code
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    symbol.isoCode,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Instructions
                if (symbol.instructions != null) ...[
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    symbol.instructions!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                
                if (symbol.temperature != null) ...[
                  const SizedBox(height: 16),
                  
                  Text(
                    'Temperature',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '${symbol.temperature}°C',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
