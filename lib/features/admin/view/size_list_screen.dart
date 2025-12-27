import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/admin_provider.dart';
import '../models/admin_models.dart' as model;
import 'edit_size_screen.dart';

class SizeListScreen extends ConsumerStatefulWidget {
  const SizeListScreen({super.key});

  @override
  ConsumerState<SizeListScreen> createState() => _SizeListScreenState();
}

class _SizeListScreenState extends ConsumerState<SizeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<model.Size> _sizes = [];

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
    List<model.Size> newSizes = [];
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        if (refresh) _paginationError = null;
      });
    }
    try {
      newSizes = await ref.read(sizesProvider(page).future);
      // Deduplicate by id
      final ids = _sizes.map((s) => s.id).toSet();
      final uniqueNew = newSizes.where((s) => !ids.contains(s.id)).toList();

      if (mounted) {
        setState(() {
          if (refresh) {
            _sizes.clear();
            _currentPage = 1;
            _hasMore = true;
          }
          if (uniqueNew.isEmpty) {
            _hasMore = false;
          } else {
            _sizes.addAll(uniqueNew);
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
      if (isError && mounted && _sizes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to load more sizes: ${_paginationError ?? ""}')),
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

  void _showAddSizeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Size'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Size Label (e.g. XL)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    final res = await ref.read(sizeControllerProvider.notifier).addSize(controller.text);
                    if (context.mounted) {
                      if (res != null) {
                        Navigator.pop(context);
                        _onRefresh(); // Refresh list after add
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Size added successfully')),
                        );
                      } else {
                         final error = ref.read(sizeControllerProvider).error;
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Error: $error')),
                         );
                      }
                    }
                  }
                },
                child: const Text('Add'),
              );
            },
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
        child: _sizes.isEmpty && _isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : _paginationError != null && _sizes.isEmpty
                ? Center(child: Text('Error: ${_paginationError}'))
                : _sizes.isEmpty && !_hasMore 
                    ? const Center(child: Text('No Sizes Found'))
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _sizes.length + (_isLoadingMore || _hasMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < _sizes.length) {
                             final size = _sizes[index];
                             return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditSizeScreen(size: size),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                      child: Text(
                                        size.sizeLabel.isNotEmpty ? size.sizeLabel.substring(0, 1) : "?",
                                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      size.sizeLabel,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
        onPressed: _showAddSizeDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

