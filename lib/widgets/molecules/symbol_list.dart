import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/data/models/care_symbol.dart';

class SymbolList extends StatelessWidget {
  const SymbolList({
    super.key,
    required this.symbols,
  });

  final List<CareSymbol> symbols;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        final symbol = symbols[index];
        return _buildSymbolCard(context, symbol);
      },
    );
  }

  Widget _buildSymbolCard(BuildContext context, CareSymbol symbol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Symbol icon placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.lightTeal,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppTheme.primaryTeal,
                size: 32,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Symbol details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    symbol.explanation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
