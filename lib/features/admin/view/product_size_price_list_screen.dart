import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_product_size_price_screen.dart';
import 'edit_product_size_price_screen.dart';

class ProductSizePriceListScreen extends ConsumerStatefulWidget {
  const ProductSizePriceListScreen({super.key});

  @override
  ConsumerState<ProductSizePriceListScreen> createState() => _ProductSizePriceListScreenState();
}

class _ProductSizePriceListScreenState extends ConsumerState<ProductSizePriceListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ProductSizePrice> _items = [];
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
    List<ProductSizePrice> newItems = [];
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        if (refresh) _paginationError = null;
      });
    }
    try {
      newItems = await ref.read(productSizePricesProvider(page).future);
      // Deduplicate by pspId
      final ids = _items.map((i) => i.pspId).toSet();
      final uniqueNew = newItems.where((i) => !ids.contains(i.pspId)).toList();
      if (mounted) {
        setState(() {
          if (refresh) {
            _items.clear();
            _currentPage = 1;
            _hasMore = true;
          }
          if (uniqueNew.isEmpty) {

            _hasMore = false;
          } else {
            _items.addAll(uniqueNew);
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
      if (isError && mounted && _items.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to load more items: ${_paginationError ?? ""}')),
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
        child: _items.isEmpty && _isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : _paginationError != null && _items.isEmpty
                ? Center(child: Text('Error: ${_paginationError}'))
                : _items.isEmpty && !_hasMore 
                    ? const Center(child: Text('No Product Size Prices found'))
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length + (_isLoadingMore || _hasMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < _items.length) {
                             final item = _items[index];
                             return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductSizePriceScreen(productSizePrice: item),
                                      ),
                                    ).then((_) {
                                       _onRefresh();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.amber.withValues(alpha: 0.1),
                                      child: Text(
                                        item.sizeName.isNotEmpty ? item.sizeName.substring(0, 1) : "?",
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
                                ),
                              );
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
                             return const Center(
                               child: Padding(
                                 padding: EdgeInsets.all(16.0),
                                 child: CircularProgressIndicator(),
                               ),
                             );
                          }
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductSizePriceScreen()),
          ).then((_) {
             _onRefresh();
          });
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}

