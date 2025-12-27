import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Category> _categories = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _paginationError;

  @override
  void initState() {
    super.initState();
    _fetchPage(_currentPage);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int page, {bool refresh = false}) async {
    if (_isLoadingMore || (!_hasMore && !refresh)) return;
    bool isError = false;
    List<Category> newCategories = [];
    setState(() {
      _isLoadingMore = true;
      if (refresh) _paginationError = null;
    });
    try {
      newCategories = await ref.read(categoriesProvider(page).future);
      // Deduplicate by id
      final ids = _categories.map((c) => c.categoryId).toSet();
      final uniqueNew = newCategories.where((c) => !ids.contains(c.categoryId)).toList();
      setState(() {
        if (refresh) {
          _categories.clear();
          _currentPage = 1;
          _hasMore = true;
        }
        if (uniqueNew.isEmpty) {
          _hasMore = false;
        } else {
          _categories.addAll(uniqueNew);
          _currentPage = page;
        }
        _paginationError = null;
      });
    } catch (e) {
      isError = true;
      setState(() {
        _paginationError = e;
      });
    } finally {
      if (mounted) {

        setState(() {
          _isLoadingMore = false;
        });
        // Check if we should load more after layout if we don't have enough to scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _hasMore && !_isLoadingMore && _scrollController.hasClients) {
            if (_scrollController.position.maxScrollExtent <= 0) {
              _fetchPage(_currentPage + 1);
            }
          }
        });
      }
      if (isError && mounted && _categories.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more categories')),
        );
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
      _fetchPage(_currentPage + 1);
    }
  }


  Future<void> _onRefresh() async {
    await _fetchPage(1, refresh: true);
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: Padding(
      padding: EdgeInsets.all(16.0),
      child: CircularProgressIndicator(),
    ));
  }

  Widget _buildErrorRetry() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Failed to load more'),
          TextButton(
            onPressed: () => _fetchPage(_currentPage + 1),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _categories.isEmpty && _isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : _paginationError != null && _categories.isEmpty
                ? Center(child: Text('Error: \\$_paginationError'))
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _categories.length + (_isLoadingMore || _hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _categories.length) {
                        final category = _categories[index];
                        return _CategoryItem(category: category, index: index);
                      } else {
                        if (_paginationError != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Failed to load more'),
                                TextButton(
                                  onPressed: () => _fetchPage(_currentPage + 1),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                    },
                  ),
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
                  tag: 'cat_img_${category.categoryId}',
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
                    tag: 'cat_img_${category.categoryId}',
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
