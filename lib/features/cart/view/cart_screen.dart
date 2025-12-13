import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/models/order.dart';
import '../notifiers/cart_notifier.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

@override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.read(cartProvider.notifier).totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: cartItems.isEmpty
          ? Center(
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
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
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
                                  imageUrl: item.product.images.first,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('Size: ${item.variant.size}  |  Qty: ${item.quantity}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                                    const SizedBox(height: 8),
                                    Text('₹${item.variant.mrp}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).removeFromCart(item);
                                    },
                                  ),
                                  Text('₹${item.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ).animate().fade().slideX(begin: 0.2, end: 0); // Animation
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                            color: Colors.red.withValues(alpha: 0.1),
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
                            Text('₹${totalAmount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final items = ref.read(cartProvider);
                              if (items.isEmpty) return;

                              final order = Order(
                                orderId: '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                date: DateTime.now(),
                                items: items.map((i) => OrderItem(
                                  productId: i.product.id,
                                  size: i.variant.size,
                                  qty: i.quantity,
                                  unitPrice: i.variant.mrp,
                                )).toList(),
                                totalQty: items.fold(0, (sum, i) => sum + i.quantity),
                                pendingQty: items.fold(0, (sum, i) => sum + i.quantity),
                                status: 'pending',
                              );

                              await ref.read(mockDataServiceProvider).addOrder(order);
                              ref.read(cartProvider.notifier).clearCart();
                              
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Order Placed!'),
                                    content: const Text('Your order has been placed successfully.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close Dialog
                                          context.go('/orders'); // Go to orders
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Text('Place Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
