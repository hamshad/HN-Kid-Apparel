
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/mock_data_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> categories = ['AFGHANI', 'KURTI', 'PLAZZO', 'GOWN', 'LEHENGA'];
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final productsFuture = ref.watch(productsProvider); // Use the provider

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        mini: true,
        child: const Icon(Icons.support_agent),
        onPressed: (){},
      ),
      body: CustomScrollView(
        slivers: [
          // Header with Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(30),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                       ],
                     ),
                     child: TextField(
                       onChanged: (value) {
                         setState(() {
                           _searchQuery = value.toLowerCase();
                         });
                       },
                       decoration: const InputDecoration(
                         hintText: 'Search for clothes...',
                         prefixIcon: Icon(Icons.search, color: Colors.grey),
                         border: InputBorder.none,
                         suffixIcon: Icon(Icons.mic, color: Colors.grey),
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),
                   if (_searchQuery.isEmpty) ...[
                      Text('Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              return _CategoryItem(label: categories[index], index: index);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                   ],
                    Text(_searchQuery.isEmpty ? 'New Arrivals' : 'Search Results', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Products Grid
          productsFuture.when(
            data: (products) {
                 final filteredProducts = _searchQuery.isEmpty 
                    ? products 
                    : products.where((p) => p.title.toLowerCase().contains(_searchQuery) || p.category.toLowerCase().contains(_searchQuery)).toList();
                 
                 if (filteredProducts.isEmpty) {
                   return const SliverFillRemaining(child: Center(child: Text("No products found")));
                 }

                 return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: filteredProducts[index])
                        .animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, delay: (50 * index).ms), // Staggered animation
                      childCount: filteredProducts.length,
                    ),
                  ),
                );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final int index;
  
  // Vibrant colors for mock categories
  static const List<Color> _colors = [
    Color(0xFFFFE0E0),
    Color(0xFFE0F7FA),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
  ];

  const _CategoryItem({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    // Generate a consistent color based on index
    final color = _colors[index % _colors.length];
    
    return InkWell(
      onTap: () {
        context.go('/tab-catalog?category=${Uri.encodeComponent(label)}');
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
               image: const DecorationImage(
                 // Using a generic fashion icon from unsplash for now as we don't have per-category images
                 image: NetworkImage("https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=200&q=80"),
                 fit: BoxFit.cover,
                 opacity: 0.8,
               ),
            ),
            child: Center(
              child: Text(
                label.substring(0, 1), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 2)]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(mockDataServiceProvider);
  return service.getProducts();
});
