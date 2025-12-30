import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';

class EditBrandScreen extends ConsumerStatefulWidget {
  final Brand brand;
  const EditBrandScreen({super.key, required this.brand});

  @override
  ConsumerState<EditBrandScreen> createState() => _EditBrandScreenState();
}

class _EditBrandScreenState extends ConsumerState<EditBrandScreen> {
  late TextEditingController _nameController;
  File? _imageFile;
  final _picker = ImagePicker();
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand.name);
    _isActive = widget.brand.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name')),
      );
      return;
    }

    // Call update API
    final res = await ref.read(brandControllerProvider.notifier).updateBrand(
      id: widget.brand.id,
      name: _nameController.text,
      imageFile: _imageFile,
      isActive: _isActive,
    );

    if (mounted) {
      if (res != null) {
        final message = res['Message'] ?? 'Brand updated successfully';
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); 
                  Navigator.pop(context, true); // Return true to signal success
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
        ref.invalidate(brandsProvider(1));
      } else {
        final state = ref.read(brandControllerProvider);
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Brand'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Brand Details",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Update the brand logo, name, or status.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Image Picker Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_imageFile!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: const Text(
                                  "Tap to Change Image",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : widget.brand.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(widget.brand.logoUrl!, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: const Text(
                                      "Tap to Change Image",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.blueGrey[200]),
                              const SizedBox(height: 16),
                              Text(
                                "Tap to Upload Logo",
                                style: TextStyle(
                                  color: Colors.blueGrey[400],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Text Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Brand Name',
                hintText: 'Enter brand name',
                prefixIcon: const Icon(Icons.branding_watermark_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Active Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                title: const Text("Is Active"),
                subtitle: const Text("Show this brand to customers"),
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 48),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blueAccent.withValues(alpha: 0.4),
                ),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Brand',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: state.isLoading ? null : _confirmDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Delete Brand',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand', style: TextStyle(color: Colors.red)),
        content: Text(
          'Are you sure you want to delete "${widget.brand.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final error = await ref.read(brandControllerProvider.notifier).deleteBrand(widget.brand.id);
      
      if (!mounted) return;

      if (error == null) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Brand deleted successfully')),
        );
        ref.invalidate(brandsProvider(1));
        Navigator.pop(context, true); // Return true to signal success
      } else {
        // Failure
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cannot Delete'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    }
  }
}
