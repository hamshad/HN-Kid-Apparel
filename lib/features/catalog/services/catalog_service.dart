import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/design_model.dart';
import '../models/category_model.dart';

final catalogServiceProvider = Provider<CatalogService>((ref) {
  final apiClient = ApiClient();
  final authService = ref.read(authServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return CatalogService(apiClient, authService, storageService);
});

class CatalogService {
  final ApiClient _apiClient;
  final AuthService _authService;
  final StorageService _storageService;

  CatalogService(this._apiClient, this._authService, this._storageService);

  Future<List<Design>> getDesigns({int page = 1, int pageSize = 10, int? categoryId}) async {
    final token = await _storageService.getToken();
    final queryParams = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    
    String path = ApiConstants.designEndpoint;
    if (categoryId != null) {
      path = '$path/category/$categoryId';
    } else {
      // If no category, we might want to ensure we hit the base endpoint correctly
      // ApiConstants.designEndpoint is likely '/api/Design'
    }
    
    final uri = Uri.parse('${ApiConstants.baseUrl}$path')
        .replace(queryParameters: queryParams);


    final response = await _apiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final designResponse = DesignResponse.fromJson(json);
      return designResponse.data;
    } else {
      throw Exception('Failed to load designs: ${response.statusCode}');
    }
  }

  Future<List<Category>> getCategories({int page = 1, int pageSize = 10}) async {
    final token = await _storageService.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoryEndpoint}')
        .replace(queryParameters: {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final response = await _apiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final categoryResponse = CategoryResponse.fromJson(json);
      return categoryResponse.data;
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<Design?> getDesignById(int designId) async {
    final token = await _storageService.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.designEndpoint}/$designId');

    final response = await _apiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Assuming the API returns a single design wrapped in the standard response format
      // If the API returns just the design object, adjust accordingly
      if (json['Success'] == true && json['Data'] != null) {
        return Design.fromJson(json['Data']);
      }
      return null;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load design: ${response.statusCode}');
    }
  }
}
