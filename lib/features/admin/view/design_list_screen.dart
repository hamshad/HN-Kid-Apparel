import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_design_screen.dart';
import 'design_detail_screen.dart';

class DesignListScreen extends ConsumerWidget {
  const DesignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designsProvider(1));

    return Scaffold(
      body: designsAsync.when(
        data: (designs) => RefreshIndicator(
          onRefresh: () => ref.refresh(designsProvider(1).future),
          child: designs.isEmpty 
          ? const Center(child: Text('No Designs Found'))
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: designs.length,
            itemBuilder: (context, index) {
              final design = designs[index];
              return _DesignItem(design: design, index: index);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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

  const _DesignItem({required this.design, required this.index});

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
                      Text("Design #: ${widget.design.designNumber}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
