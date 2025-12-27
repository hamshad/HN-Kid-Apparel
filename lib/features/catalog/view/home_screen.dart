import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/product_card.dart';
import '../providers/catalog_provider.dart';
import '../models/category_model.dart';
import '../../../core/constants/api_constants.dart';



// Local Category class removed in favor of unified model in catalog/models/category_model.dart


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final productsFuture = ref.watch(
      designListProvider,
    ); // Use the real provider

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both products and categories
          ref.invalidate(designListProvider);
          ref.invalidate(categoryListProvider);
          await Future.wait([
            ref.read(designListProvider.future),
            ref.read(categoryListProvider.future),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            // Header with Search
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "HN Kids Apparel",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Wholesale Shopping",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () => context.push('/wishlist'),
                                  icon: const Icon(Icons.favorite_border),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () => context.push('/cart'),
                                  icon: const Icon(Icons.shopping_bag_outlined),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for clothes...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune,
                                size: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_searchQuery.isEmpty) ...[
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Categories Section
                        Consumer(
                          builder: (context, ref, child) {
                            final categoriesAsync = ref.watch(
                              categoryListProvider,
                            );

                            return categoriesAsync.when(
                              data: (categories) {
                                if (categories.isEmpty)
                                  return const SizedBox.shrink();
                                return SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final cat = categories[index];
                                      return _CategoryItem(
                                        label: cat.name,
                                        imageUrl: cat.imageUrl,
                                        index: index,
                                      );
                                    },
                                  ),
                                );
                              },
                              loading: () => const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (error, stack) => const SizedBox.shrink(),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        _searchQuery.isEmpty
                            ? 'New Arrivals'
                            : 'Search Results',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Products Grid
            productsFuture.when(
              data: (products) {
                final filteredProducts = _searchQuery.isEmpty
                    ? products
                    : products
                          .where(
                            (p) =>
                                p.title.toLowerCase().contains(_searchQuery) ||
                                p.category.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                if (filteredProducts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No products found")),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ProductCard(product: filteredProducts[index])
                              .animate()
                              .fade(duration: 400.ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                delay: (50 * index).ms,
                              ), // Staggered animation
                      childCount: filteredProducts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final String imageUrl;
  final int index;

  // Vibrant colors for mock categories
  static const List<Color> _colors = [
    Color(0xFFFFE0E0),
    Color(0xFFE0F7FA),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
  ];

  const _CategoryItem({
    required this.label,
    required this.imageUrl,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a consistent color based on index
    final color = _colors[index % _colors.length];

    // Construct full image URL
    final fullImageUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiConstants.baseUrl}$imageUrl';

    return InkWell(
      onTap: () {
        // Category filtering can be implemented here if needed
        // For now, categories are just visual indicators
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
              image: DecorationImage(
                // Using specific category image
                image: NetworkImage(fullImageUrl),
                fit: BoxFit.cover,
                opacity: 0.8,
                onError: (_, __) {
                  // Fallback or error handling if needed
                },
              ),
            ),
            child: Center(
              child: Text(
                label.isNotEmpty ? label.substring(0, 1) : '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
