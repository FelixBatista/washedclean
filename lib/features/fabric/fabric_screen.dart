import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/services/favorites_service.dart';

class FabricScreen extends ConsumerWidget {
  const FabricScreen({
    super.key,
    required this.fabricId,
  });

  final String fabricId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final favoritesService = ref.watch(favoritesServiceProvider.notifier);
    final isFavorite = ref.watch(favoritesServiceProvider).contains(fabricId);
    
    final fabric = contentService.getFabricById(fabricId);

    if (fabric == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fabric Not Found')),
        body: const Center(
          child: Text('Fabric not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(fabric.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.pop();
            } catch (e) {
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
            onPressed: () => favoritesService.toggleFavorite(fabricId),
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
                Icons.checkroom,
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
                  // Title
                  Text(
                    fabric.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Overview
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  MarkdownBody(
                    data: fabric.overviewMd,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Care Instructions
                  Text(
                    'Care Instructions',
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
                      data: fabric.stepsMd,
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
                  
                  // Common Stains
                  if (fabric.commonStains.isNotEmpty) ...[
                    Text(
                      'Common Stains',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: fabric.commonStains.map((stainId) {
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
                  
                  // Recommended Products
                  if (fabric.recommendedProducts.isNotEmpty) ...[
                    Text(
                      'Recommended Products',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ...fabric.recommendedProducts.map((productId) {
                      final product = contentService.getProductById(productId);
                      if (product == null) return const SizedBox.shrink();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
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
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
