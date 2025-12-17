import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';

class EditDesignScreen extends ConsumerStatefulWidget {
  final Design design;
  const EditDesignScreen({super.key, required this.design});

  @override
  ConsumerState<EditDesignScreen> createState() => _EditDesignScreenState();
}

class _EditDesignScreenState extends ConsumerState<EditDesignScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _designNumberController;
  late bool _isNew;
  late bool _isActive;
  
  int? _selectedBrandId;
  int? _selectedCategoryId;
  int? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.design.title);
    _designNumberController = TextEditingController(text: widget.design.designNumber);
    _isNew = widget.design.isNew;
    _isActive = widget.design.isActive;
    _selectedBrandId = widget.design.brandId;
    _selectedCategoryId = widget.design.categoryId;
    _selectedSeriesId = widget.design.seriesId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _designNumberController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBrandId == null || _selectedCategoryId == null || _selectedSeriesId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Brand, Category and Series')),
      );
      return;
    }

    final res = await ref.read(designControllerProvider.notifier).updateDesign(
      id: widget.design.id,
      title: _titleController.text,
      designNumber: _designNumberController.text,
      categoryId: _selectedCategoryId!,
      seriesId: _selectedSeriesId!,
      brandId: _selectedBrandId!,
      isNew: _isNew,
      isActive: _isActive,
    );

    if (mounted) {
      if (res != null) {
        final message = res['Message'] ?? 'Design updated successfully';
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Go back to Detail
                  Navigator.pop(context); // Go back to List (optional, but detail might be better to stay) 
                  // Wait, pop context goes to Detail screen. If we stay there, we need to refresh it.
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Design', style: TextStyle(color: Colors.red)),
        content: Text(
          'Are you sure you want to delete "${widget.design.title}"? This action cannot be undone.',
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
      final error = await ref.read(designControllerProvider.notifier).deleteDesign(widget.design.id);
      
      if (!mounted) return;

      if (error == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Design deleted successfully')),
        );
        ref.invalidate(designsProvider(1));
        Navigator.pop(context); // Pop Edit Screen
        Navigator.pop(context); // Pop Detail Screen to go back to list
      } else {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(designControllerProvider);
    final brandsAsync = ref.watch(allBrandsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final seriesAsync = ref.watch(allSeriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Design'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Design Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
               const SizedBox(height: 8),
              Text(
                "Update the design information below.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Design Title', Icons.title),
                validator: (val) => val == null || val.isEmpty ? 'Please enter title' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _designNumberController,
                decoration: _inputDecoration('Design Number', Icons.numbers),
                validator: (val) => val == null || val.isEmpty ? 'Please enter design number' : null,
              ),
              const SizedBox(height: 16),

              // Brand Dropdown
              brandsAsync.when(
                data: (brands) => DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: brands.any((b) => b.id == _selectedBrandId) ? _selectedBrandId : null,
                  decoration: _inputDecoration('Brand', Icons.branding_watermark),
                  items: brands.map((b) => DropdownMenuItem(value: b.id, child: Row(
                    children: [
                      if (b.logoUrl != null) 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(b.logoUrl!, width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox(width: 24)),
                        )
                      else const SizedBox(width: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Text(b.name, overflow: TextOverflow.ellipsis)),
                    ],
                  ))).toList(),
                  onChanged: (val) => setState(() => _selectedBrandId = val),
                  validator: (value) => value == null ? 'Please select a brand' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e,s) => Text('Error loading brands: $e'),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              categoriesAsync.when(
                data: (cats) => DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: cats.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
                  decoration: _inputDecoration('Category', Icons.category),
                  items: cats.map((c) => DropdownMenuItem(value: c.id, child: Row(
                    children: [
                      if (c.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(c.imageUrl!, width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox(width: 24)),
                        )
                      else const SizedBox(width: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
                    ],
                  ))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (value) => value == null ? 'Please select a category' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e,s) => Text('Error loading categories: $e'),
              ),
              const SizedBox(height: 16),

              // Series Dropdown
              seriesAsync.when(
                data: (seriesList) => DropdownButtonFormField<int>(
                  value: seriesList.any((s) => s.id == _selectedSeriesId) ? _selectedSeriesId : null,
                  decoration: _inputDecoration('Series', Icons.layers),
                  items: seriesList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _selectedSeriesId = val),
                  validator: (value) => value == null ? 'Please select a series' : null,
                 ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading series: $e'),
              ),
              const SizedBox(height: 24),

              // Toggles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Is New Arrival"),
                      value: _isNew,
                      onChanged: (val) => setState(() => _isNew = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text("Is Active"),
                      subtitle: const Text("Show this design to customers"),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

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
                          'Update Design',
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
                    'Delete Design',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
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
    );
  }
}
