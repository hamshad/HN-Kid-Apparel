import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/wishlist/providers/wishlist_provider.dart';
import '../models/product.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  void _toggleLike() {
    final designId = int.tryParse(widget.product.id);
    if (designId != null) {
      ref.read(wishlistProvider.notifier).toggleWishlist(designId);
    }
  }

  void _shareProduct() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share via', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.chat_bubble,
                    color: Colors.green,
                    label: 'WhatsApp',
                  ),
                  _buildShareOption(
                    icon: Icons.camera_alt,
                    color: Colors.purple,
                    label: 'Instagram',
                  ),
                  _buildShareOption(
                    icon: Icons.email,
                    color: Colors.red,
                    label: 'Gmail',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Shared to $label')));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designId = int.tryParse(widget.product.id) ?? 0;
    final isLiked = ref.watch(
      wishlistProvider.select(
        (value) =>
            value.valueOrNull?.any((item) => item.designId == designId) ??
            false,
      ),
    );

    return GestureDetector(
      onTap: () => context.go('/product/${widget.product.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_${widget.product.id}',
                    child: widget.product.images.isEmpty
                        ? Container(
                            color: Colors.grey[200],
                            width: double.infinity,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : widget.product.images.length > 1
                        ? PageView.builder(
                            itemCount: widget.product.images.length,
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: widget.product.images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              );
                            },
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.product.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                  // Action Buttons
                  if (widget.product.isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        _buildActionButton(
                          icon: isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          onTap: _toggleLike,
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          icon: Icons.share,
                          color: Colors.black54,
                          onTap: _shareProduct,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildPrice(context),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: widget.product.variants
                        .take(4)
                        .map(
                          (v) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              v.size,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (widget.product.variants.length > 4) ...[
                    const SizedBox(height: 2),
                    Text(
                      "+${widget.product.variants.length - 4} more",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    if (widget.product.variants.isEmpty) return const SizedBox.shrink();

    final prices = widget.product.variants.map((v) => v.mrp).toList();
    if (prices.isEmpty) return const SizedBox.shrink();

    prices.sort();
    final minPrice = prices.first;

    return Text(
      '\$${minPrice.toStringAsFixed(0)}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
