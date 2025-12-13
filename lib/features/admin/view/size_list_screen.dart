import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';
import '../provider/admin_provider.dart';

class SizeListScreen extends ConsumerStatefulWidget {
  const SizeListScreen({super.key});

  @override
  ConsumerState<SizeListScreen> createState() => _SizeListScreenState();
}

class _SizeListScreenState extends ConsumerState<SizeListScreen> {
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Implement pagination load more if needed
      // ensuring unique items & request debouncing
    }
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
                        ref.invalidate(sizesProvider(_page));
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
    final sizesAsync = ref.watch(sizesProvider(_page));

    return Scaffold(
      body: sizesAsync.when(
        data: (sizes) => sizes.isEmpty
            ? const Center(child: Text('No sizes found'))
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: sizes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final size = sizes[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        child: Text(
                          size.sizeLabel.substring(0, 1),
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        size.sizeLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSizeDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
