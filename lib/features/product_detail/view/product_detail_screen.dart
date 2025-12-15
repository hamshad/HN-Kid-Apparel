import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/models/product.dart';
import '../../cart/providers/cart_provider.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';

import '../../../core/theme/app_theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Consumer(builder: (context, ref, child) {
            final designId = int.tryParse(widget.id) ?? 0;
            final isLiked = ref.watch(wishlistProvider.select(
              (value) => value.valueOrNull?.any((item) => item.designId == designId) ?? false
            ));
            return IconButton(
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
              onPressed: () => ref.read(wishlistProvider.notifier).toggleWishlist(designId),
            );
          }),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'), // Push to keep back stack
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) return const Center(child: Text('Product not found'));
          
          // Initialize selection only once
          if (_selectedVariant == null && product.variants.isNotEmpty) {
             _selectedVariant = product.variants.first;
          } else if (product.variants.isEmpty) {
             // Create a dummy variant if none exist (for UI safety)
             _selectedVariant = ProductVariant(size: "Free", mrp: 0, availableQty: 0);
          }

          final variant = _selectedVariant ?? (product.variants.isNotEmpty ? product.variants.first : ProductVariant(size: "Free", mrp: 0, availableQty: 0));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productDetailsProvider(widget.id));
              await ref.read(productDetailsProvider(widget.id).future);
            },
            child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      if (product.images.isNotEmpty)
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 400.0,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: false,
                          ),
                          items: product.images.map((url) {
                            return CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                            );
                          }).toList(),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "SKU: ${product.sku}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              product.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            


                            // Size Selection
                            Text("Select Size", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children: product.variants.map((v) {
                                final isSelected = variant == v;
                                return ChoiceChip(
                                  label: Text(v.size),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedVariant = v;
                                        _quantity = 1; // Reset qty on size change
                                      });
                                    }
                                  },
                                  selectedColor: AppTheme.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                             // Price and Stock
                             Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                 color: Colors.grey[50],
                                 borderRadius: BorderRadius.circular(12),
                                 border: Border.all(color: Colors.grey.shade200),
                               ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         "Price",
                                         style: Theme.of(context).textTheme.bodySmall,
                                       ),
                                       Text(
                                         "₹${variant.mrp}",
                                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                           color: AppTheme.primary,
                                           fontWeight: FontWeight.bold
                                         ),
                                       ),
                                     ],
                                   ),
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.end,
                                     children: [
                                       Text(
                                         "Stock",
                                         style: Theme.of(context).textTheme.bodySmall,
                                       ),
                                        Text(
                                         "${variant.availableQty} units",
                                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                           color: variant.availableQty < 10 ? Colors.orange : Colors.green,
                                           fontWeight: FontWeight.w600,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 24),

                             // Quantity Selector
                             Row(
                               children: [
                                 Text("Quantity", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                 const Spacer(),
                                 Container(
                                   decoration: BoxDecoration(
                                     border: Border.all(color: Colors.grey.shade300),
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Row(
                                     children: [
                                       IconButton(
                                         onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                         icon: const Icon(Icons.remove),
                                         color: AppTheme.primary,
                                       ),
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 12),
                                         child: Text("$_quantity", style: Theme.of(context).textTheme.titleMedium),
                                       ),
                                       IconButton(
                                         onPressed: () => setState(() => _quantity++),
                                         icon: const Icon(Icons.add),
                                          color: AppTheme.primary,
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                                final designId = int.tryParse(product.id) ?? 0;
                                ref.read(cartProvider.notifier).addToCart(
                                  designId: designId, 
                                  sizeId: variant.sizeId, 
                                  quantity: _quantity
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to Cart'),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(16),
                                  ),
                                );
                              },
                          child: const Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// Provider for fetching specific product details
final productDetailsProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final products = await ref.watch(designListProvider.future);
  try {
    return products.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
});
