import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/wishlist_model.dart';

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  final apiClient = ApiClient();
  final authService = ref.read(authServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return WishlistService(apiClient, authService, storageService);
});

class WishlistService {
  final ApiClient _apiClient;
  final AuthService _authService;
  final StorageService _storageService;

  WishlistService(this._apiClient, this._authService, this._storageService);

  Future<WishlistItem> addToWishlist(int designId) async {
    final token = await _storageService.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wishlistEndpoint}');

    final response = await _apiClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'DesignId': designId,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final wishlistItemResponse = WishlistItemResponse.fromJson(json);
      return wishlistItemResponse.data;
    } else {
      throw Exception('Failed to add item to wishlist: ${response.statusCode}');
    }
  }

  Future<List<WishlistItem>> getWishlist({int page = 1, int pageSize = 10}) async {
    final token = await _storageService.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myWishlistEndpoint}')
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
      final wishlistListResponse = WishlistListResponse.fromJson(json);
      return wishlistListResponse.data;
    } else {
      throw Exception('Failed to retrieve wishlist: ${response.statusCode}');
    }
  }

  Future<void> removeFromWishlist(int wishlistId) async {
    final token = await _storageService.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wishlistEndpoint}/$wishlistId');

    final response = await _apiClient.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from wishlist: ${response.statusCode}');
    }
  }
}
