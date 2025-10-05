import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/services/favorites_service.dart';

class ProductScreen extends ConsumerWidget {
  const ProductScreen({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final favoritesService = ref.watch(favoritesServiceProvider.notifier);
    final isFavorite = ref.watch(favoritesServiceProvider).contains(productId);
    
    final product = contentService.getProductById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
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
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.urgencyRed : null,
            ),
            onPressed: () => favoritesService.toggleFavorite(productId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image placeholder
            Container(
              width: double.infinity,
              height: 200,
              color: AppTheme.lightTeal,
              child: const Icon(
                Icons.shopping_bag,
                size: 64,
                color: AppTheme.primaryTeal,
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and subtitle
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    product.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Allergen warnings
                  if (product.allergenFlags.isNotEmpty) ...[
                    Text(
                      'Allergen Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.urgencyRed,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.urgencyRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.urgencyRed.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: product.allergenFlags.map((allergen) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                size: 16,
                                color: AppTheme.urgencyRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                allergen.replaceAll('_', ' ').toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.urgencyRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Ingredients
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightTeal),
                    ),
                    child: MarkdownBody(
                      data: product.ingredientsMd,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                        strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // How to use
                  Text(
                    'How to Use',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightTeal),
                    ),
                    child: MarkdownBody(
                      data: product.howToUseMd,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                        strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Removes stains
                  if (product.removesStains.isNotEmpty) ...[
                    Text(
                      'Removes These Stains',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.removesStains.map((stainId) {
                        final stain = contentService.getStainById(stainId);
                        if (stain == null) return const SizedBox.shrink();
                        
                        return GestureDetector(
                          onTap: () => context.go('/stain/${stain.id}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.urgencyRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.urgencyRed.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              stain.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.urgencyRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Compatible fabrics
                  if (product.fitsFabrics.isNotEmpty) ...[
                    Text(
                      'Compatible Fabrics',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.fitsFabrics.map((fabricId) {
                        final fabric = contentService.getFabricById(fabricId);
                        if (fabric == null) return const SizedBox.shrink();
                        
                        return GestureDetector(
                          onTap: () => context.go('/fabric/${fabric.id}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              fabric.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Buy button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // In a real app, you would use url_launcher here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening ${product.name} on Amazon...'),
                            backgroundColor: AppTheme.primaryTeal,
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Buy on Amazon'),
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
