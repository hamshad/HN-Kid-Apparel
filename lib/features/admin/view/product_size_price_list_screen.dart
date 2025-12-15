import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/admin_provider.dart';
import 'add_product_size_price_screen.dart';

class ProductSizePriceListScreen extends ConsumerStatefulWidget {
  const ProductSizePriceListScreen({super.key});

  @override
  ConsumerState<ProductSizePriceListScreen> createState() => _ProductSizePriceListScreenState();
}

class _ProductSizePriceListScreenState extends ConsumerState<ProductSizePriceListScreen> {
  final int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pspAsync = ref.watch(productSizePricesProvider(_page));

    return Scaffold(
      body: pspAsync.when(
        data: (items) => items.isEmpty
            ? const Center(child: Text('No Product Size Prices found'))
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.withValues(alpha: 0.1),
                        child: Text(
                          item.sizeName,
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        item.designName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Size: ${item.sizeName}'),
                      trailing: Text(
                        '₹${item.price.toStringAsFixed(2)}',
                         style: const TextStyle(
                           fontWeight: FontWeight.bold,
                           color: Colors.green
                         ),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductSizePriceScreen()),
          ).then((_) {
             ref.invalidate(productSizePricesProvider(_page));
          });
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
