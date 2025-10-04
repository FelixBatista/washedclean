import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/search_service.dart';
import '../../widgets/molecules/search_bar.dart';

class SearchScreen extends HookConsumerWidget {
  final String query;
  
  const SearchScreen({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchService = ref.watch(searchServiceProvider);
    final searchController = useTextEditingController(text: query);
    final searchResults = useState<List<SearchResult>>([]);
    final isLoading = useState(false);

    useEffect(() {
      if (query.isNotEmpty) {
        _performSearch(query, searchService, searchResults, isLoading);
      }
      return null;
    }, [query]);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AppSearchBar(
              controller: searchController,
              onSearch: (query) {
                if (query.isNotEmpty) {
                  _performSearch(query, searchService, searchResults, isLoading);
                }
              },
            ),
          ),
          
          // Results
          Expanded(
            child: isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : searchResults.value.isEmpty
                    ? _buildNoResults(context)
                    : _buildResults(context, searchResults.value),
          ),
        ],
      ),
    );
  }

  void _performSearch(
    String query,
    SearchService searchService,
    ValueNotifier<List<SearchResult>> searchResults,
    ValueNotifier<bool> isLoading,
  ) {
    isLoading.value = true;
    Future.microtask(() {
      final results = searchService.search(query);
      searchResults.value = results;
      isLoading.value = false;
    });
  }

  Widget _buildNoResults(BuildContext context) {
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
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for stains, fabrics, or products',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<SearchResult> results) {
    // Group results by type
    final stains = results.where((r) => r.type == 'stain').toList();
    final fabrics = results.where((r) => r.type == 'fabric').toList();
    final products = results.where((r) => r.type == 'product').toList();
    final articles = results.where((r) => r.type == 'article').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (stains.isNotEmpty) ...[
          _buildSectionHeader(context, 'Stains', stains.length),
          const SizedBox(height: 8),
          ...stains.map((result) => _buildStainCard(context, result)),
          const SizedBox(height: 24),
        ],
        
        if (fabrics.isNotEmpty) ...[
          _buildSectionHeader(context, 'Fabrics', fabrics.length),
          const SizedBox(height: 8),
          ...fabrics.map((result) => _buildFabricCard(context, result)),
          const SizedBox(height: 24),
        ],
        
        if (products.isNotEmpty) ...[
          _buildSectionHeader(context, 'Products', products.length),
          const SizedBox(height: 8),
          ...products.map((result) => _buildProductCard(context, result)),
          const SizedBox(height: 24),
        ],
        
        if (articles.isNotEmpty) ...[
          _buildSectionHeader(context, 'Articles', articles.length),
          const SizedBox(height: 8),
          ...articles.map((result) => _buildArticleCard(context, result)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStainCard(BuildContext context, SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.urgencyRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.water_drop,
            color: AppTheme.urgencyRed,
          ),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go('/stain/${result.id}'),
      ),
    );
  }

  Widget _buildFabricCard(BuildContext context, SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.checkroom,
            color: AppTheme.primaryTeal,
          ),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go('/fabric/${result.id}'),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.urgencyYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.shopping_bag,
            color: AppTheme.urgencyYellow,
          ),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go('/product/${result.id}'),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.article,
            color: AppTheme.primaryTeal,
          ),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go('/article/${result.id}'),
      ),
    );
  }
}
