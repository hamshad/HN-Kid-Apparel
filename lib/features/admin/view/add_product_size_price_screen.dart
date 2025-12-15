import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';
import '../provider/admin_provider.dart';

class AddProductSizePriceScreen extends ConsumerStatefulWidget {
  const AddProductSizePriceScreen({super.key});

  @override
  ConsumerState<AddProductSizePriceScreen> createState() => _AddProductSizePriceScreenState();
}

class _AddProductSizePriceScreenState extends ConsumerState<AddProductSizePriceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedDesignId;
  int? _selectedSizeId;
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedDesignId != null && _selectedSizeId != null) {
       final price = double.tryParse(_priceController.text);
       if (price == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid price')));
         return;
       }

       final res = await ref.read(productSizePriceControllerProvider.notifier).addProductSizePrice(
         _selectedDesignId!,
         _selectedSizeId!,
         price,
       );

       if (mounted) {
         if (res != null) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successfully')));
           Navigator.pop(context);
         } else {
           final error = ref.read(productSizePriceControllerProvider).error;
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add: $error')));
         }
       }
    } else {
      if (_selectedDesignId == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a design')));
      } else if (_selectedSizeId == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a size')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetching larger list for dropdowns
    final designsAsync = ref.watch(allDesignsProvider); 
    final sizesAsync = ref.watch(allSizesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product Size Price')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Design Dropdown
              designsAsync.when(
                data: (designs) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Design', border: OutlineInputBorder()),
                  value: _selectedDesignId,
                  items: designs.map((d) => DropdownMenuItem(
                    value: d.id,
                    child: Row(
                      children: [
                        if (d.images.isNotEmpty) ...[
                           ClipRRect(
                             borderRadius: BorderRadius.circular(4),
                             child: Image.network(
                               d.images.first,
                               width: 40,
                               height: 40,
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey),
                             ),
                           ),
                           const SizedBox(width: 12),
                        ],
                        Expanded(child: Text('${d.title} (${d.designNumber})', overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedDesignId = val),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e,s) => Text('Error loading designs: $e'),
              ),
              const SizedBox(height: 16),
              
              // Size Dropdown
              sizesAsync.when(
                data: (sizes) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Size', border: OutlineInputBorder()),
                  value: _selectedSizeId,
                  items: sizes.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.sizeLabel),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedSizeId = val),
                 ),
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e,s) => Text('Error loading sizes: $e'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), prefixText: '₹ '),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter price';
                  if (double.tryParse(val) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(productSizePriceControllerProvider);
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _submit,
                      child: state.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Add Product Size Price'),
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
