import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/content_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/ratings_service.dart';
import '../../core/services/stain_solution_service.dart';
import '../../core/data/models/stain.dart';
import '../../core/data/models/stain_solution.dart';
import '../../widgets/atoms/urgency_chip.dart';
import '../../widgets/atoms/rating_bar.dart';

class StainScreen extends HookConsumerWidget {
  const StainScreen({
    super.key,
    required this.stainId,
    this.fabricId,
  });

  final String stainId;
  final String? fabricId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentServiceProvider);
    final favoritesService = ref.watch(favoritesServiceProvider.notifier);
    final ratingsService = ref.watch(ratingsServiceProvider.notifier);
    
    final stain = contentService.getStainById(stainId);
    final selectedFabricId = useState(fabricId);
    final isFavorite = ref.watch(favoritesServiceProvider).contains(stainId);

    // Load stain solution from Firebase
    final stainSolutionAsync = ref.watch(stainSolutionByTitleProvider(stain?.name ?? ''));

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
              Builder(
                builder: (context) {
                  final tips = _getTipsForFabric(stain, selectedFabricId.value ?? stain.byFabric.first.fabricId);
                  if (tips != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            color: AppTheme.lightTeal.withValues(alpha: 0.3),
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
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            
            // Detailed Solutions from Firebase
            stainSolutionAsync.when(
              data: (solution) {
                if (solution != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailedSolution(context, solution),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => const SizedBox.shrink(),
            ),

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

  Widget _buildDetailedSolution(BuildContext context, StainSolution solution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Removal Guide',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTeal,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // General notes
        if (solution.introNotes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTeal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...solution.introNotes.take(2).map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '• $note',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Cautions
        if (solution.cautions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.urgencyRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.urgencyRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.urgencyRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cautions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.urgencyRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...solution.cautions.map((caution) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '⚠️ $caution',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: AppTheme.darkGray,
                    ),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Sections by material type
        ...solution.sections.map((section) => _buildSolutionSection(context, section)),
      ],
    );
  }

  Widget _buildSolutionSection(BuildContext context, SolutionSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTeal),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cleaning_services,
              color: AppTheme.primaryTeal,
              size: 24,
            ),
          ),
          title: Text(
            section.sectionName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          children: section.methods.map((method) => _buildMethod(context, method)).toList(),
        ),
      ),
    );
  }

  Widget _buildMethod(BuildContext context, SolutionMethod method) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Materials needed
        if (method.materials.isNotEmpty) ...[
          Text(
            'Materials Needed:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          ...method.materials.map((material) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    material,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        
        // Steps
        if (method.steps.isNotEmpty) ...[
          Text(
            'Steps:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          ...method.steps.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        
        // Notes
        if (method.notes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Information:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...method.notes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    note,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
        
        // Method cautions
        if (method.cautions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...method.cautions.map((caution) => Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppTheme.urgencyRed.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.urgencyRed,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    caution,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }
}
