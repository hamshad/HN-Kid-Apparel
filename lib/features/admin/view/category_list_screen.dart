import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider(1));

    return Scaffold(
      body: categoriesAsync.when(
        data: (categories) => RefreshIndicator(
          onRefresh: () => ref.refresh(categoriesProvider(1).future),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(category: category, index: index);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final int index;

  const _CategoryItem({required this.category, required this.index});

  void _showFullscreen(BuildContext context) {
    if (category.imageUrl == null) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black.withValues(alpha: 0.9),
            body: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Center(
                child: Hero(
                  tag: 'cat_img_${category.id}',
                  child: Image.network(
                    category.imageUrl!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (ctx, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditCategoryScreen(category: category),
              ),
            );
          },
          onLongPress: () => _showFullscreen(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Hero(
                    tag: 'cat_img_${category.id}',
                    child: category.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              category.imageUrl!,
                              fit: BoxFit.cover, // Using cover as requested for square look
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.category, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).scale(delay: (50 * index).ms);
  }
}
