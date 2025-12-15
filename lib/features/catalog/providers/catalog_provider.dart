import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/product.dart';
import '../models/category_model.dart';
import '../services/catalog_service.dart';

final designListProvider = FutureProvider<List<Product>>((ref) async {
  final catalogService = ref.watch(catalogServiceProvider);
  final designs = await catalogService.getDesigns();
  
  // Convert Designs to Products for UI consumption
  return designs.map((design) => Product.fromDesign(design)).toList();
});

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final catalogService = ref.watch(catalogServiceProvider);
  return await catalogService.getCategories();
});
