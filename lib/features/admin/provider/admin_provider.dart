import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/provider/auth_provider.dart'; // To access storage service via provider potentially or directly
import '../services/admin_service.dart';
import '../models/admin_models.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AdminService(storageService);
});

// --- Brands ---

final brandsProvider = FutureProvider.autoDispose.family<List<Brand>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getBrands(page, 10); // Default pageSize 10
});

class BrandController extends StateNotifier<AsyncValue<void>> {
  final AdminService _adminService;

  BrandController(this._adminService) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> addBrand(String name, File imageFile) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.addBrand(name, imageFile);
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateBrand({
    required int id,
    required String name,
    File? imageFile,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.updateBrand(
        id: id,
        name: name,
        imageFile: imageFile,
        isActive: isActive
      );
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<String?> deleteBrand(int id) async {
    state = const AsyncLoading();
    try {
      await _adminService.deleteBrand(id);
      state = const AsyncData(null);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}

final brandControllerProvider = StateNotifierProvider<BrandController, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return BrandController(adminService);
});

// --- Categories ---

final categoriesProvider = FutureProvider.autoDispose.family<List<Category>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getCategories(page, 10);
});

class CategoryController extends StateNotifier<AsyncValue<void>> {
  final AdminService _adminService;

  CategoryController(this._adminService) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> addCategory(String name, File imageFile) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.addCategory(name, imageFile);
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
  Future<Map<String, dynamic>?> updateCategory({
    required int id,
    required String name,
    File? imageFile,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.updateCategory(
        id: id,
        name: name,
        imageFile: imageFile,
        isActive: isActive
      );
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<String?> deleteCategory(int id) async {
    state = const AsyncLoading();
    try {
      await _adminService.deleteCategory(id);
      state = const AsyncData(null);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}

final categoryControllerProvider = StateNotifierProvider<CategoryController, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return CategoryController(adminService);
});

// --- Series ---

final seriesProvider = FutureProvider.autoDispose.family<List<Series>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getSeries(page, 10);
});

class SeriesController extends StateNotifier<AsyncValue<void>> {
  final AdminService _adminService;

  SeriesController(this._adminService) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> addSeries(String name) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.addSeries(name);
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final seriesControllerProvider = StateNotifierProvider<SeriesController, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return SeriesController(adminService);
});

// --- Designs ---

final designsProvider = FutureProvider.autoDispose.family<List<Design>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getDesigns(page, 10);
});

class DesignController extends StateNotifier<AsyncValue<void>> {
  final AdminService _adminService;

  DesignController(this._adminService) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> addDesign({
    required String title,
    required String designNumber,
    required int categoryId,
    required int seriesId,
    required int brandId,
    required bool isNew,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.addDesign(
        title: title, 
        designNumber: designNumber, 
        categoryId: categoryId, 
        seriesId: seriesId, 
        brandId: brandId, 
        isNew: isNew
      );
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
  Future<void> uploadDesignImages(int designId, List<File> images) async {
    state = const AsyncLoading();
    try {
      for (final image in images) {
        await _adminService.addDesignImage(designId, image);
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> uploadDesignImage(int designId, File image) async {
    state = const AsyncLoading();
    try {
      await _adminService.addDesignImage(designId, image);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final designControllerProvider = StateNotifierProvider<DesignController, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return DesignController(adminService);
});

final designImagesProvider = FutureProvider.autoDispose.family<List<DesignImage>, int>((ref, designId) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getDesignImages(designId);
});

// --- Sizes ---

class SizeController extends StateNotifier<AsyncValue<void>> {
  final AdminService _adminService;

  SizeController(this._adminService) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> addSize(String label) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.addSize(label);
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final sizeControllerProvider = StateNotifierProvider<SizeController, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return SizeController(adminService);
});

final sizesProvider = FutureProvider.autoDispose.family<List<Size>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getSizes(page, 20);
});

// --- Product Size Price ---

class ProductSizePriceController extends StateNotifier<AsyncValue<void>> {
  final AdminService _adminService;

  ProductSizePriceController(this._adminService) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> addProductSizePrice(int designId, int sizeId, double price) async {
    state = const AsyncLoading();
    try {
      final res = await _adminService.addProductSizePrice(designId, sizeId, price);
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final productSizePriceControllerProvider = StateNotifierProvider<ProductSizePriceController, AsyncValue<void>>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return ProductSizePriceController(adminService);
});

final productSizePricesProvider = FutureProvider.autoDispose.family<List<ProductSizePrice>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getProductSizePrices(page, 20);
});

// Providers for Dropdowns (fetch larger list)
final allDesignsProvider = FutureProvider.autoDispose<List<Design>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getDesigns(1, 100);
});

final allSizesProvider = FutureProvider.autoDispose<List<Size>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getSizes(1, 100);
});

// --- Users ---

final usersProvider = FutureProvider.autoDispose.family<List<User>, int>((ref, page) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.getUsers(page, 10);
});
