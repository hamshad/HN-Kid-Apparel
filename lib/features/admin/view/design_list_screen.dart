import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_design_screen.dart';
import 'design_detail_screen.dart';

class DesignListScreen extends ConsumerStatefulWidget {
  const DesignListScreen({super.key});

  @override
  ConsumerState<DesignListScreen> createState() => _DesignListScreenState();
}

class _DesignListScreenState extends ConsumerState<DesignListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Design> _designs = [];
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
    List<Design> newDesigns = [];
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        if (refresh) _paginationError = null;
      });
    }
    try {
      newDesigns = await ref.read(designsProvider(page).future);
      // Deduplicate by id
      final ids = _designs.map((d) => d.id).toSet();
      final uniqueNew = newDesigns.where((d) => !ids.contains(d.id)).toList();
      if (mounted) {
        setState(() {
          if (refresh) {
            _designs.clear();
            _currentPage = 1;
            _hasMore = true;
          }
          if (uniqueNew.isEmpty) {
            _hasMore = false;
          } else {
            _designs.addAll(uniqueNew);
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
      if (isError && mounted && _designs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more designs')),
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
        child: _designs.isEmpty && _isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : _paginationError != null && _designs.isEmpty
                ? Center(child: Text('Error: ${_paginationError}'))
                : _designs.isEmpty && !_hasMore 
                    ? const Center(child: Text('No Designs Found'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _designs.length + (_isLoadingMore || _hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _designs.length) {
                             final design = _designs[index];
                             return _DesignItem(design: design, index: index, key: ValueKey(design.id)); // Add key for stability
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
            MaterialPageRoute(builder: (context) => const AddDesignScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class _DesignItem extends ConsumerStatefulWidget {
  final Design design;
  final int index;

  const _DesignItem({super.key, required this.design, required this.index});

  @override
  ConsumerState<_DesignItem> createState() => _DesignItemState();
}

class _DesignItemState extends ConsumerState<_DesignItem> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      
      final file = File(pickedFile.path);
      await ref.read(designControllerProvider.notifier).uploadDesignImage(widget.design.id, file);
      
      final state = ref.read(designControllerProvider);
      
      if (mounted) {
        setState(() => _isUploading = false);
        if (!state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
          ref.invalidate(designsProvider(1));
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${state.error}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DesignDetailScreen(design: widget.design),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                if (widget.design.images.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.design.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.design.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.design.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Text('NEW', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Product #: ${widget.design.designNumber}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildTag(Icons.branding_watermark, widget.design.brandName),
                          _buildTag(Icons.category, widget.design.categoryName),
                          _buildTag(Icons.layers, widget.design.seriesName),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.add_a_photo, size: 18),
                label: Text(_isUploading ? 'Uploading...' : 'Add Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, delay: (50 * widget.index).ms));
  }

  Widget _buildTag(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueAccent),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
        ],
      ),
    );
  }
}
