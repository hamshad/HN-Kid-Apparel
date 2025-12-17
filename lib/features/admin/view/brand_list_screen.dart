import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_brand_screen.dart';
import 'edit_brand_screen.dart';

class BrandListScreen extends ConsumerWidget {
  const BrandListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basic pagination mock - just loading page 1 for now
    final brandsAsync = ref.watch(brandsProvider(1));

    return Scaffold(
      body: brandsAsync.when(
        data: (brands) => RefreshIndicator(
          onRefresh: () async {
            // Invalidate to reload
             return ref.refresh(brandsProvider(1).future);
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns as requested
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85, // Adjusted for compact look
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return _BrandItem(brand: brand, index: index);
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
            MaterialPageRoute(builder: (context) => const AddBrandScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BrandItem extends StatelessWidget {
  final Brand brand;
  final int index;

  const _BrandItem({required this.brand, required this.index});

  void _showFullscreen(BuildContext context) {
    if (brand.logoUrl == null) return;
    
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
                  tag: 'brand_logo_${brand.id}',
                  child: Image.network(
                    brand.logoUrl!,
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
                builder: (context) => EditBrandScreen(brand: brand),
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
                    tag: 'brand_logo_${brand.id}',
                    child: brand.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              brand.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.branding_watermark, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  brand.name,
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
