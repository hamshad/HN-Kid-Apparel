import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, AsyncValue<Order?>>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return OrderNotifier(orderService);
});

class OrderNotifier extends StateNotifier<AsyncValue<Order?>> {
  final OrderService _orderService;

  OrderNotifier(this._orderService) : super(const AsyncValue.data(null));

  Future<void> placeOrder() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _orderService.placeOrder();
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
