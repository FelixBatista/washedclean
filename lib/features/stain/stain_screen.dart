import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/ratings_service.dart';
import '../../widgets/atoms/urgency_chip.dart';
import '../../widgets/atoms/rating_bar.dart';

class StainScreen extends HookConsumerWidget {
  final String stainId;
  final String? fabricId;

  const StainScreen({
    super.key,
    required this.stainId,
    this.fabricId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final favoritesService = ref.watch(favoritesServiceProvider.notifier);
    final ratingsService = ref.watch(ratingsServiceProvider.notifier);
    
    final stain = contentService.getStainById(stainId);
    final selectedFabricId = useState(fabricId);
    final isFavorite = ref.watch(favoritesServiceProvider).contains(stainId);
    final rating = ref.watch(ratingsServiceProvider)[stainId];

    if (stain == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stain Not Found')),
        body: const Center(
          child: Text('Stain not found'),
        ),
      );
    }

    // Get the selected fabric or first available
    final selectedFabric = selectedFabricId.value != null
        ? contentService.getFabricById(selectedFabricId.value!)
        : stain.byFabric.isNotEmpty
            ? contentService.getFabricById(stain.byFabric.first.fabricId)
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(stain.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.urgencyRed : null,
            ),
            onPressed: () => favoritesService.toggleFavorite(stainId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with urgency
            Row(
              children: [
                Expanded(
                  child: Text(
                    stain.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                UrgencyChip(urgency: stain.urgency),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              stain.summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Fabric selector
            if (stain.byFabric.length > 1) ...[
              Text(
                'Select Fabric Type',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stain.byFabric.map((stainFabric) {
                  final fabric = contentService.getFabricById(stainFabric.fabricId);
                  final isSelected = selectedFabricId.value == stainFabric.fabricId;
                  
                  return GestureDetector(
                    onTap: () {
                      selectedFabricId.value = stainFabric.fabricId;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.mediumGray,
                        ),
                      ),
                      child: Text(
                        fabric?.name ?? stainFabric.fabricId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppTheme.white : AppTheme.darkGray,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Instructions
            if (selectedFabric != null) ...[
              Text(
                'Instructions for ${selectedFabric.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightTeal),
                ),
                child: Text(
                  _getInstructionsForFabric(stain, selectedFabricId.value ?? stain.byFabric.first.fabricId),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tips
              final tips = _getTipsForFabric(stain, selectedFabricId.value ?? stain.byFabric.first.fabricId);
              if (tips != null) ...[
                Text(
                  'Pro Tips',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTeal.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tips,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ],
            
            // Rating section
            _buildRatingSection(context, stainId, ratingsService),
            
            const SizedBox(height: 24),
            
            // Related products
            if (stain.relatedProducts.isNotEmpty) ...[
              Text(
                'Recommended Products',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              ...stain.relatedProducts.map((productId) {
                final product = contentService.getProductById(productId);
                if (product == null) return const SizedBox.shrink();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(product.subtitle),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/product/${product.id}'),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  String _getInstructionsForFabric(Stain stain, String fabricId) {
    final stainFabric = stain.byFabric.firstWhere(
      (sf) => sf.fabricId == fabricId,
      orElse: () => stain.byFabric.first,
    );
    return stainFabric.stepsMd;
  }

  String? _getTipsForFabric(Stain stain, String fabricId) {
    final stainFabric = stain.byFabric.firstWhere(
      (sf) => sf.fabricId == fabricId,
      orElse: () => stain.byFabric.first,
    );
    return stainFabric.tipsMd;
  }

  Widget _buildRatingSection(BuildContext context, String stainId, RatingsService ratingsService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Was this helpful?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          RatingBar(
            onRatingChanged: (rating) {
              ratingsService.setRating(stainId, rating);
            },
          ),
        ],
      ),
    );
  }
}
