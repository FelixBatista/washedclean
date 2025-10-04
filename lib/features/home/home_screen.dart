import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../widgets/molecules/search_bar.dart';
import '../../widgets/molecules/article_card.dart';
import '../../widgets/atoms/urgency_chip.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final featuredArticles = contentService.featuredArticles;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
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
              child: Column(
                children: [
                  // App title
                  Text(
                    'Washed Clean',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search bar
                  AppSearchBar(
                    onSearch: (query) {
                      if (query.isNotEmpty) {
                        context.go('/search?q=$query');
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick actions
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 24),
                    
                    // Featured articles
                    Text(
                      'Featured Articles',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Articles list
                    if (featuredArticles.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: featuredArticles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final article = featuredArticles[index];
                          return ArticleCard(
                            article: article,
                            onTap: () => context.go('/article/${article.id}'),
                          );
                        },
                      )
                    else
                      const Center(
                        child: Text('No featured articles available'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Floating Action Button for camera
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/camera'),
        backgroundColor: AppTheme.primaryTeal,
        child: const Icon(
          Icons.camera_alt,
          color: AppTheme.white,
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.go('/articles');
              break;
            case 2:
              context.go('/favorites');
              break;
            case 3:
              context.go('/camera');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.search,
                title: 'Search Stains',
                subtitle: 'Find solutions',
                color: AppTheme.urgencyRed,
                onTap: () => context.go('/search?q=stain'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.checkroom,
                title: 'Fabric Care',
                subtitle: 'Care guides',
                color: AppTheme.primaryTeal,
                onTap: () => context.go('/search?q=fabric'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.shopping_bag,
                title: 'Products',
                subtitle: 'Recommended',
                color: AppTheme.urgencyYellow,
                onTap: () => context.go('/search?q=product'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.camera_alt,
                title: 'Scan Label',
                subtitle: 'Read symbols',
                color: AppTheme.primaryTeal,
                onTap: () => context.go('/camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
