import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final selectedCategory = useState<String>('WINE');

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Teal droplet icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: AppTheme.white,
                          size: 40,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Main message
                      Text(
                        'Don\'t worry! We have a solution to remove stains from your clothes.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Search bar
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightGray,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search "How to remove wine stains."',
                            hintStyle: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.primaryTeal,
                              size: 24,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (query) {
                            if (query.isNotEmpty) {
                              context.go('/search?q=$query');
                            }
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Category filter buttons
                      _buildCategoryFilters(context, selectedCategory),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
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
              context.go('/favorites');
              break;
            case 2:
              context.go('/camera');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, ValueNotifier<String> selectedCategory) {
    final categories = ['Grease', 'WINE', 'Beer', 'Ink', 'Ketchup', 'Coffee', 'Blood', 'Oil'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory.value == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                selectedCategory.value = category;
                context.go('/search?q=$category');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryTeal : AppTheme.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.lightGray,
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? AppTheme.white : AppTheme.darkGray,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
