import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

final cartProvider = AsyncNotifierProvider<CartNotifier, Cart>(() {
  return CartNotifier();
});

class CartNotifier extends AsyncNotifier<Cart> {
  // Use a getter instead of late final to avoid reinitialization issues
  CartService get _cartService => ref.read(cartServiceProvider);

  @override
  Future<Cart> build() async {
    return _cartService.getCart();
  }

  Future<void> refreshCart() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _cartService.getCart());
  }

  Future<void> addToCart({
    required int designId,
    required int sizeId,
    required int quantity,
  }) async {
    // We don't set state to loading here to avoid full screen rebuilds if not desired, 
    // but ensuring UI feedback is handled by the caller or specialized state.
    // However, for consistency, let's keep the main cart state valid.
    await _cartService.addToCart(designId: designId, sizeId: sizeId, quantity: quantity);
    
    // Refresh cart to get updated totals and structure
    // We could optimize by appending the returned item, but TotalAmount would be stale.
    await refreshCart(); 
  }

  Future<void> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    // Get the current state for rollback if needed
    final previousState = state;
    
    // Optimistic update: immediately update the UI
    state.whenData((cart) {
      final updatedItems = cart.cartItems.map((item) {
        return item.cartItemId == cartItemId 
            ? item.copyWith(quantity: quantity)
            : item;
      }).toList();
      
      // Update the state with the new items
      // Note: TotalAmount will be recalculated when we refresh from API
      // For now, we keep the old total (it will be corrected after API call)
      state = AsyncValue.data(Cart(
        cartId: cart.cartId,
        userId: cart.userId,
        createdAt: cart.createdAt,
        cartItems: updatedItems,
        totalAmount: cart.totalAmount, // Keep old total temporarily
      ));
    });
    
    // Make the API call in the background
    try {
      await _cartService.updateCartItem(cartItemId: cartItemId, quantity: quantity);
      // Silently refresh to get the correct total amount
      final updatedCart = await _cartService.getCart();
      state = AsyncValue.data(updatedCart);
    } catch (e, st) {
      // If the API call fails, revert to the previous state
      state = previousState;
      // Re-throw the error so the UI can show an error message if needed
      rethrow;
    }
  }
}
