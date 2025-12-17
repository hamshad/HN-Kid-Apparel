import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/cart_model.dart';



class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Use ref.refresh for AsyncNotifier instead of invalidate
          return ref.refresh(cartProvider.future);
        },
        child: cartAsync.when(
        data: (cart) {
          if (cart.cartItems.isEmpty) {
            return _buildEmptyCart(context);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.cartItems[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              _buildSummary(context, ref, cart),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    // Wrap in ListView to make it scrollable for RefreshIndicator
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Text('Start Shopping'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, WidgetRef ref, Cart cart) {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '₹${cart.totalAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final orderNotifier = ref.read(orderProvider.notifier);
                  
                  try {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    // Place the order
                    await orderNotifier.placeOrder();
                    
                    // Close loading dialog
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    
                    // Get the order result
                    final orderState = ref.read(orderProvider);
                    
                    orderState.when(
                      data: (order) {
                        if (order != null && context.mounted) {
                          // Show success dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Order Placed Successfully!'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order Number: ${order.orderNumber}'),
                                  const SizedBox(height: 8),
                                  Text('Total Items: ${order.totalQty}'),
                                  const SizedBox(height: 8),
                                  Text('Status: ${order.status}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Refresh cart to clear it
                                    ref.read(cartProvider.notifier).refreshCart();
                                    // Reset order state
                                    orderNotifier.reset();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      loading: () {},
                      error: (err, stack) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to place order: $err'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  } catch (e) {
                    // Close loading dialog if still open
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to place order: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Attempt to fetch price if needed, or just display what we have.
    // Since API doesn't give price per item, we might skip it or fetch it.
    // For now, let's just display the item details we have.
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.designImageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.designName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${item.sizeLabel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: item.quantity > 1 
                              ? () async {
                                  try {
                                    await ref.read(cartProvider.notifier).updateQuantity(
                                      cartItemId: item.cartItemId, 
                                      quantity: item.quantity - 1
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update quantity: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () async {
                            try {
                              await ref.read(cartProvider.notifier).updateQuantity(
                                cartItemId: item.cartItemId, 
                                quantity: item.quantity + 1
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update quantity: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // We can add a fetch for price here if strictly needed
             Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // If we had unit price, we would show it. 
                // Since we don't, we just show nothing or maybe a loader if we fetch it?
                // Text('₹???', style: Theme.of(context).textTheme.titleMedium),
              ],
            )
          ],
        ),
      ),
    ).animate().fade().slideX(begin: 0.2, end: 0);
  }
}
