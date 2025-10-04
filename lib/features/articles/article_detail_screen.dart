import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/services/favorites_service.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final favoritesService = ref.watch(favoritesServiceProvider.notifier);
    final isFavorite = ref.watch(favoritesServiceProvider).contains(articleId);
    
    final article = contentService.getArticleById(articleId);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article Not Found')),
        body: const Center(
          child: Text('Article not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.urgencyRed : null,
            ),
            onPressed: () => favoritesService.toggleFavorite(articleId),
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
                Icons.article,
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
                    article.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    article.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tags
                  if (article.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: article.tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: AppTheme.lightTeal,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Article content
                  MarkdownBody(
                    data: article.bodyMd,
                    styleSheet: MarkdownStyleSheet(
                      h1: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                      strong: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      em: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // CTA Button
                  if (article.cta != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (article.cta!.route.startsWith('/')) {
                            context.go(article.cta!.route);
                          } else {
                            // Handle external links
                            // You would use url_launcher here
                          }
                        },
                        child: Text(article.cta!.label),
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
