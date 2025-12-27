import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';

class AddDesignScreen extends ConsumerStatefulWidget {
  const AddDesignScreen({super.key});

  @override
  ConsumerState<AddDesignScreen> createState() => _AddDesignScreenState();
}

class _AddDesignScreenState extends ConsumerState<AddDesignScreen> {
  final _titleController = TextEditingController();
  final _designNumberController = TextEditingController();
  int? _selectedBrandId;
  int? _selectedCategoryId;
  int? _selectedSeriesId;
  bool _isNew = true;

  void _submit() async {
    if (_titleController.text.isEmpty ||
        _designNumberController.text.isEmpty ||
        _selectedBrandId == null ||
        _selectedCategoryId == null ||
        _selectedSeriesId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final res = await ref.read(designControllerProvider.notifier).addDesign(
          title: _titleController.text,
          designNumber: _designNumberController.text,
          categoryId: _selectedCategoryId!,
          seriesId: _selectedSeriesId!,
          brandId: _selectedBrandId!,
          isNew: _isNew,
        );

    if (mounted) {
      if (res != null) {
        final message = res['Message'] ?? 'Design added successfully';
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
        ref.invalidate(designsProvider(1));
      } else {
        final state = ref.read(designControllerProvider);
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
    final state = ref.watch(designControllerProvider);
    final brandsAsync = ref.watch(brandsProvider(1));
    final categoriesAsync = ref.watch(categoriesProvider(1));
    final seriesAsync = ref.watch(seriesProvider(1));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Product'),
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
              "Create New Product",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Fill in the details to create a new Product.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Title
            _buildTextField(
              controller: _titleController,
              label: 'Product Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 16),

            // Design Number
            _buildTextField(
              controller: _designNumberController,
              label: 'Product Number',
              icon: Icons.numbers,
            ),
            const SizedBox(height: 16),

            // Brand Dropdown
            _buildDropdown<Brand>(
              value: _selectedBrandId,
              items: brandsAsync.value ?? [],
              label: 'Select Brand',
              icon: Icons.branding_watermark_outlined,
              isLoading: brandsAsync.isLoading,
              onChanged: (val) => setState(() => _selectedBrandId = val),
              itemLabelBuilder: (item) => item.name,
              itemValueBuilder: (item) => item.id,
              itemImageBuilder: (item) => item.logoUrl,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            _buildDropdown<Category>(
              value: _selectedCategoryId,
              items: categoriesAsync.value ?? [],
              label: 'Select Category',
              icon: Icons.category_outlined,
              isLoading: categoriesAsync.isLoading,
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              itemLabelBuilder: (item) => item.name,
              itemValueBuilder: (item) => item.categoryId,
              itemImageBuilder: (item) => item.imageUrl,
            ),
            const SizedBox(height: 16),

            // Series Dropdown
            _buildDropdown<Series>(
              value: _selectedSeriesId,
              items: seriesAsync.value ?? [],
              label: 'Select Series',
              icon: Icons.layers_outlined,
              isLoading: seriesAsync.isLoading,
              onChanged: (val) => setState(() => _selectedSeriesId = val),
              itemLabelBuilder: (item) => item.name,
              itemValueBuilder: (item) => item.id,
            ),
            const SizedBox(height: 24),

            // Is New Toggle
            SwitchListTile(
              title: const Text("Is New Arrival?", style: TextStyle(fontWeight: FontWeight.w600)),
              value: _isNew,
              onChanged: (val) => setState(() => _isNew = val),
              activeTrackColor: Colors.blueAccent.withValues(alpha: 0.5),
              activeThumbColor: Colors.blueAccent,
              contentPadding: EdgeInsets.zero,
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
                        'Create Product',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
    );
  }

  Widget _buildDropdown<T>({
    required int? value,
    required List<T> items,
    required String label,
    required IconData icon,
    required bool isLoading,
    required ValueChanged<int?> onChanged,
    required String Function(T) itemLabelBuilder,
    required int Function(T) itemValueBuilder,
    String? Function(T)? itemImageBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                hint: Row(children: [
                  Icon(icon, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(label)
                ]),
                isExpanded: true,
                onChanged: onChanged,
                icon: const Icon(Icons.arrow_drop_down),
                items: items.map((item) {
                  final imageUrl =
                      itemImageBuilder != null ? itemImageBuilder(item) : null;
                  return DropdownMenuItem<int>(
                    value: itemValueBuilder(item),
                    child: Row(
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              imageUrl,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(icon, color: Colors.blueAccent, size: 24),
                            ),
                          )
                        else
                          Icon(icon, color: Colors.blueAccent, size: 24),
                        const SizedBox(width: 12),
                        Container(
                           constraints: const BoxConstraints(maxWidth: 200),
                           child: Text(
                             itemLabelBuilder(item),
                             overflow: TextOverflow.ellipsis,
                           ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
