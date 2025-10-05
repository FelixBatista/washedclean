import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/services/favorites_service.dart';

class FavoritesScreen extends HookConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final favoritesService = ref.watch(favoritesServiceProvider.notifier);
    final favorites = ref.watch(favoritesServiceProvider);
    final selectedFilter = useState<String?>(null);

    // Get favorite items
    final favoriteItems = <FavoriteItem>[];
    
    for (final itemId in favorites) {
      // Try to find the item in different content types
      final stain = contentService.getStainById(itemId);
      if (stain != null) {
        favoriteItems.add(FavoriteItem(
          id: stain.id,
          title: stain.name,
          subtitle: stain.summary,
          type: 'stain',
          icon: Icons.water_drop,
          color: AppTheme.urgencyRed,
        ));
        continue;
      }

      final fabric = contentService.getFabricById(itemId);
      if (fabric != null) {
        favoriteItems.add(FavoriteItem(
          id: fabric.id,
          title: fabric.name,
          subtitle: 'Fabric care guide',
          type: 'fabric',
          icon: Icons.checkroom,
          color: AppTheme.primaryTeal,
        ));
        continue;
      }

      final product = contentService.getProductById(itemId);
      if (product != null) {
        favoriteItems.add(FavoriteItem(
          id: product.id,
          title: product.name,
          subtitle: product.subtitle,
          type: 'product',
          icon: Icons.shopping_bag,
          color: AppTheme.urgencyYellow,
        ));
        continue;
      }
    }

    // Filter items
    final filteredItems = selectedFilter.value == null
        ? favoriteItems
        : favoriteItems.where((item) => item.type == selectedFilter.value).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkGray,
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
          if (favoriteItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Favorites'),
                    content: const Text('Are you sure you want to remove all favorites?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          favoritesService.clearFavorites();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          // Filter chips
          if (favoriteItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      'All',
                      null,
                      selectedFilter.value,
                      () => selectedFilter.value = null,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Articles',
                      'article',
                      selectedFilter.value,
                      () => selectedFilter.value = 'article',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Stains',
                      'stain',
                      selectedFilter.value,
                      () => selectedFilter.value = 'stain',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Fabrics',
                      'fabric',
                      selectedFilter.value,
                      () => selectedFilter.value = 'fabric',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Products',
                      'product',
                      selectedFilter.value,
                      () => selectedFilter.value = 'product',
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Content
          Expanded(
            child: favoriteItems.isEmpty
                ? _buildEmptyState(context)
                : filteredItems.isEmpty
                    ? _buildNoFilteredResults(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildFavoriteCard(context, item, favoritesService);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String? value,
    String? selectedValue,
    VoidCallback onTap,
  ) {
    final isSelected = selectedValue == value;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.mediumGray,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppTheme.white : AppTheme.darkGray,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any item to add it to favorites',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilteredResults(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.filter_list_off,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    FavoriteItem item,
    FavoritesService favoritesService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: item.color,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: AppTheme.urgencyRed),
              onPressed: () => favoritesService.toggleFavorite(item.id),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          switch (item.type) {
            case 'stain':
              context.go('/stain/${item.id}');
              break;
            case 'fabric':
              context.go('/fabric/${item.id}');
              break;
            case 'product':
              context.go('/product/${item.id}');
              break;
          }
        },
      ),
    );
  }
}

class FavoriteItem {
  FavoriteItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final Color color;
}
