import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_brand_screen.dart';
import 'edit_brand_screen.dart';

class BrandListScreen extends ConsumerStatefulWidget {
  const BrandListScreen({super.key});

  @override
  ConsumerState<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends ConsumerState<BrandListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Brand> _brands = [];
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
    List<Brand> newBrands = [];
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        if (refresh) _paginationError = null;
      });
    }
    try {
      newBrands = await ref.read(brandsProvider(page).future);
      // Deduplicate by id
      final ids = _brands.map((b) => b.id).toSet();
      final uniqueNew = newBrands.where((b) => !ids.contains(b.id)).toList();
      if (mounted) {
        setState(() {
          if (refresh) {
            _brands.clear();
            _currentPage = 1;
            _hasMore = true;
          }
          if (uniqueNew.isEmpty) {
            _hasMore = false;
          } else {
            _brands.addAll(uniqueNew);
            _currentPage = page;
          }
          _paginationError = null;
        });
      }
    } catch (e) {
      isError = true;
      if (mounted) {
        setState(() {
          _paginationError = e;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        // Check if we should load more after layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _hasMore && !_isLoadingMore && _scrollController.hasClients) {
            if (_scrollController.position.maxScrollExtent <= 0) {
              _fetchPage(_currentPage + 1);
            }
          }
        });
      }
      if (isError && mounted && _brands.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more brands')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _brands.isEmpty && _isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : _paginationError != null && _brands.isEmpty
                ? Center(child: Text('Error: ${_paginationError}'))
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _brands.length + (_isLoadingMore || _hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _brands.length) {
                        final brand = _brands[index];
                        return _BrandItem(brand: brand, index: index);
                      } else {
                        if (_paginationError != null) {
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
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBrandScreen()),
          );
          // Refresh list if brand was added
          if (result == true && mounted) {
            _onRefresh();
          }
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
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditBrandScreen(brand: brand),
              ),
            );
            // Refresh list if brand was updated or deleted
            if (result == true && context.mounted) {
              // Find the parent BrandListScreen state and refresh
              context.findAncestorStateOfType<_BrandListScreenState>()?._onRefresh();
            }
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
