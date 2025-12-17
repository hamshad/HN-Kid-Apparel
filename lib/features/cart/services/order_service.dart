import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/order_model.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final apiClient = ApiClient();
  final authService = ref.read(authServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return OrderService(apiClient, authService, storageService);
});

class OrderService {
  final ApiClient _apiClient;
  final AuthService _authService;
  final StorageService _storageService;

  OrderService(this._apiClient, this._authService, this._storageService);

  Future<Order> placeOrder() async {
    final token = await _storageService.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orderEndpoint}');

    final response = await _apiClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final orderResponse = OrderResponse.fromJson(json);
      return orderResponse.data;
    } else {
      throw Exception('Failed to place order: ${response.statusCode}');
    }
  }
}
