import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/product.dart';
import '../models/category_model.dart';
import '../services/catalog_service.dart';

class DesignFilter {
  final int page;
  final int? categoryId;

  const DesignFilter({required this.page, this.categoryId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DesignFilter &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          categoryId == other.categoryId;

  @override
  int get hashCode => page.hashCode ^ categoryId.hashCode;
}

final designsProvider = FutureProvider.family<List<Product>, DesignFilter>((
  ref,
  filter,
) async {
  final catalogService = ref.watch(catalogServiceProvider);
  final designs = await catalogService.getDesigns(
    page: filter.page,
    pageSize: 20,
    categoryId: filter.categoryId,
  );
  return designs.map((design) => Product.fromDesign(design)).toList();
});

final categoriesProvider = FutureProvider.family<List<Category>, int>((
  ref,
  page,
) async {
  final catalogService = ref.watch(catalogServiceProvider);
  return await catalogService.getCategories(page: page, pageSize: 10);
});

// Keep legacy provider for backward compatibility if needed, or remove.
// For now, redirecting to page 1.
final designListProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(designsProvider(const DesignFilter(page: 1)).future);
});

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(categoriesProvider(1).future);
});

// Provider to fetch a single product by ID directly from API
final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final catalogService = ref.watch(catalogServiceProvider);
  final designId = int.tryParse(id);
  
  if (designId == null) return null;
  
  final design = await catalogService.getDesignById(designId);
  if (design == null) return null;
  
  return Product.fromDesign(design);
});
