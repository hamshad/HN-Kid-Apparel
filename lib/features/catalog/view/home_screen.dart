import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/product_card.dart';
import '../providers/catalog_provider.dart';
import '../models/category_model.dart';
import '../../../shared/models/product.dart';
import '../../../core/constants/api_constants.dart';



// Local Category class removed in favor of unified model in catalog/models/category_model.dart


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = "";
  
  // Product Pagination State
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  int _productPage = 1;
  bool _isProductLoading = false;
  bool _hasMoreProducts = true;
  Object? _productsError;
  int? _selectedCategoryId;

  // Category Pagination State
  final ScrollController _categoryScrollController = ScrollController();
  List<Category> _categories = [];
  int _categoryPage = 1;
  bool _isCategoryLoading = false;
  bool _hasMoreCategories = true;
  Object? _categoriesError;

  @override
  void initState() {
    super.initState();
    _fetchCategories(1);
    _fetchProducts(1);
    _scrollController.addListener(_onMainScroll);
    _categoryScrollController.addListener(_onCategoryScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onMainScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_hasMoreProducts && !_isProductLoading) {
        _fetchProducts(_productPage + 1);
      }
    }
  }

  void _onCategoryScroll() {
    if (!_categoryScrollController.hasClients) return;
    if (_categoryScrollController.position.pixels >= _categoryScrollController.position.maxScrollExtent - 100) {
      if (_hasMoreCategories && !_isCategoryLoading) {
        _fetchCategories(_categoryPage + 1);
      }
    }
  }

  Future<void> _fetchProducts(int page, {bool refresh = false}) async {
    if (_isProductLoading || (!_hasMoreProducts && !refresh)) return;

    if (mounted) {
      setState(() {
        _isProductLoading = true;
        if (refresh) _productsError = null;
      });
    }

    try {
      final filter = DesignFilter(page: page, categoryId: _selectedCategoryId);
      
      if (refresh) {
        // Force refresh from server
        ref.invalidate(designsProvider(filter));
      }

      final newProducts = await ref.read(designsProvider(filter).future);
      
      if (mounted) {
        setState(() {
          if (refresh) {
            _products = newProducts;
            _productPage = 1;
            // Check if initial load is already smaller than page size (10)
            _hasMoreProducts = newProducts.length >= 10;
          } else {
            // Deduplicate only when appending
            final ids = _products.map((p) => p.id).toSet();
            final uniqueNew = newProducts.where((p) => !ids.contains(p.id)).toList();
            
            if (uniqueNew.isNotEmpty) {
              _products.addAll(uniqueNew);
            }
            
            _productPage = page;
              
            // If we fetched fewer than pageSize (10), we reached the end
            if (newProducts.length < 10) {
              _hasMoreProducts = false;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _productsError = e);
    } finally {
      if (mounted) setState(() => _isProductLoading = false);
    }
  }

  Future<void> _fetchCategories(int page, {bool refresh = false}) async {
    debugPrint('[CAT-PAGINATION] _fetchCategories called with page=$page, refresh=$refresh');
    debugPrint('[CAT-PAGINATION] Current state: _isCategoryLoading=$_isCategoryLoading, _hasMoreCategories=$_hasMoreCategories, _categoryPage=$_categoryPage, _categories.length=${_categories.length}');
    
    if (_isCategoryLoading || (!_hasMoreCategories && !refresh)) {
      debugPrint('[CAT-PAGINATION] BLOCKED: isLoading=$_isCategoryLoading, hasMore=$_hasMoreCategories, refresh=$refresh');
      return;
    }

    if (mounted) {
      setState(() {
        _isCategoryLoading = true;
        _categoriesError = null;
      });
    }

    try {
      if (refresh) {
        debugPrint('[CAT-PAGINATION] Invalidating provider for page $page');
        ref.invalidate(categoriesProvider(page));
      }

      debugPrint('[CAT-PAGINATION] Fetching page $page from provider...');
      final newCategories = await ref.read(categoriesProvider(page).future);
      debugPrint('[CAT-PAGINATION] Received ${newCategories.length} categories from API');

      if (mounted) {
        final int oldLength = _categories.length;
        
        setState(() {
          if (refresh) {
            // Fresh start
            _categories = List<Category>.from(newCategories);
            _categoryPage = 1;
            debugPrint('[CAT-PAGINATION] REFRESH: Set _categories to ${_categories.length} items');
          } else {
            // GUARANTEED APPEND: Create new list with all existing + all new
            final List<Category> updatedList = List<Category>.from(_categories);
            debugPrint('[CAT-PAGINATION] APPEND: Starting with ${updatedList.length} existing items');
            updatedList.addAll(newCategories);
            debugPrint('[CAT-PAGINATION] APPEND: After addAll, list has ${updatedList.length} items');
            _categories = updatedList;
            _categoryPage = page;
            debugPrint('[CAT-PAGINATION] APPEND: Assigned to _categories, now has ${_categories.length} items');
          }
          
          // Determine if more pages exist
          _hasMoreCategories = newCategories.length >= 10;
          debugPrint('[CAT-PAGINATION] Set _hasMoreCategories=$_hasMoreCategories (fetched ${newCategories.length} items)');
        });
        
        debugPrint('[CAT-PAGINATION] SUCCESS: List grew from $oldLength to ${_categories.length} items');
      } else {
        debugPrint('[CAT-PAGINATION] WARNING: Widget not mounted, skipping setState');
      }
    } catch (e) {
      debugPrint('[CAT-PAGINATION] ERROR: $e');
      if (mounted) setState(() => _categoriesError = e);
    } finally {
      if (mounted) setState(() => _isCategoryLoading = false);
      debugPrint('[CAT-PAGINATION] DONE: _isCategoryLoading set to false');
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (_selectedCategoryId == categoryId) {
      // Toggle off if same selected, or maybe just ignore?
      // Let's allow deselection to clear filter
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
    }
    _products.clear();
    _hasMoreProducts = true;
    _fetchProducts(1, refresh: true);
  }

  Future<void> _onRefresh() async {
    // Refresh both products (respecting filter) and categories (resetting)
    // Actually, usually refreshing PullToRefresh shouldn't clear categories unless we want to valid updates
    // But it definitely should refresh the current product view
    
    // Note: If we want to keep "Independent on initial", then refreshing should maybe fetch default?
    // But user probably wants to refresh what they see.
    // Let's refresh current state.
    
    // If we want to reset strict "initial" state:
    // _selectedCategoryId = null; 
    
    await Future.wait([
       _fetchProducts(1, refresh: true),
       _fetchCategories(1, refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
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
                      // ... (App Bar Content same as before) ...
                      const SizedBox(height: 8),
                      // ... (Header Row same as before) ...
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
                      // Search Bar
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
                                // Client side search filter or Server side?
                                // "add pagination... map categories with design api"
                                // Search implementation was client side before.
                                // With pagination, client side search only searches loaded items.
                                // Ideally should be server search.
                                // For now, let's keep it simple: Update local query, 
                                // wait, if we support search API we'd call it.
                                // The user request focused on Category mapping.
                                // I'll leave search as visual filter on *loaded* items for now or remove if it conflicts?
                                // The original code filtered `productsFuture` data.
                                // I will NOT implement server search unless requested, but I'll filter _products locally for display?
                                // Actually, filtering only loaded products is confusing.
                                // But usually "Add pagination" implies server-side data.
                                // Providing a disclaimer: Search currently only filters loaded items.
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
                         SizedBox(
                                  height: 110,
                                    child: _categories.isEmpty && _isCategoryLoading 
                                    ? const Center(child: CircularProgressIndicator()) 
                                    : ListView.separated(
                                    controller: _categoryScrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _categories.length + (_hasMoreCategories ? 1 : 0),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      if (index < _categories.length) {
                                          final cat = _categories[index];
                                          final isSelected = cat.categoryId == _selectedCategoryId;
                                          return GestureDetector(
                                            onTap: () => _onCategorySelected(cat.categoryId),
                                            child: Column(
                                              children: [
                                                AnimatedContainer(
                                                  duration: 200.ms,
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                                                      width: 2.5,
                                                    ),
                                                    boxShadow: isSelected ? [
                                                      BoxShadow(
                                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      )
                                                    ] : null,
                                                  ),
                                                  child: _CategoryItem(
                                                    label: cat.name,
                                                    imageUrl: cat.imageUrl,
                                                    index: index,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  cat.name,
                                                  style: TextStyle(
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                                                    fontSize: 12,
                                                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                      } else {
                                        if (_categoriesError != null) {
                                          return SizedBox(
                                            width: 60,
                                            child: Center(
                                              child: IconButton(
                                                icon: const Icon(Icons.refresh, color: Colors.red),
                                                onPressed: () => _fetchCategories(_categoryPage + 1),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox(width: 60, child: Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2))));
                                      }
                                    },
                                  ),
                                ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Search Results'
                            : _selectedCategoryId != null
                                ? _categories
                                    .firstWhere(
                                      (c) => c.categoryId == _selectedCategoryId,
                                      orElse: () => Category(
                                        categoryId: 0,
                                        name: 'Category Products',
                                        imageUrl: '',
                                        isActive: true,
                                        createdDate: DateTime.now(),
                                      ),
                                    )
                                    .name

                                : 'New Arrivals',
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
            _productsError != null && _products.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text('Error loading products: $_productsError'),
                          TextButton(
                            onPressed: () => _fetchProducts(1, refresh: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _products.isEmpty && !_isProductLoading
                    ? const SliverFillRemaining(
                        child: Center(child: Text("No products found")),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < _products.length) {
                                return ProductCard(
                                  product: _products[index],
                                  showNewTag: _searchQuery.isEmpty && _selectedCategoryId == null,
                                )
                                    .animate()
                                    .fade(duration: 400.ms)
                                    .slideY(
                                      begin: 0.1,
                                      end: 0,
                                      delay: (50 * (index % 10)).ms,
                                    );
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                            childCount: _products.length + (_hasMoreProducts ? 1 : 0),
                          ),
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

    // Removed InkWell to prevent swallowing gesture events
    return Container(
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
    );
  }
}

