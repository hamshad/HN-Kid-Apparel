import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistItem>>(() {
  return WishlistNotifier();
});

class WishlistNotifier extends AsyncNotifier<List<WishlistItem>> {
  late final WishlistService _wishlistService;

  @override
  Future<List<WishlistItem>> build() async {
    _wishlistService = ref.read(wishlistServiceProvider);
    return _wishlistService.getWishlist();
  }

  Future<void> refreshWishlist() async {
    // state = const AsyncValue.loading(); // Optional: show loading spinner globally
    state = await AsyncValue.guard(() => _wishlistService.getWishlist());
  }

  /// returns true if added, false if removed (or just refreshes)
  Future<void> toggleWishlist(int designId) async {
    final currentList = state.value ?? [];
    final existingIndex = currentList.indexWhere((item) => item.designId == designId);
    
    if (existingIndex >= 0) {
      // Already in wishlist -> Remove
      final wishlistId = currentList[existingIndex].wishlistId;
      
      // Optimistic update
      final updatedList = List<WishlistItem>.from(currentList)..removeAt(existingIndex);
      state = AsyncValue.data(updatedList);

      try {
        await _wishlistService.removeFromWishlist(wishlistId);
      } catch (e) {
        // Revert on failure
        state = await AsyncValue.guard(() => _wishlistService.getWishlist());
        throw e;
      }
    } else {
      // Not in wishlist -> Add
      // We can't do fully optimistic update because we need the WishlistId from server
      // to support subsequent remove actions.
      // So we wait for response.
      try {
        final newItem = await _wishlistService.addToWishlist(designId);
        final updatedList = [newItem, ...currentList];
        state = AsyncValue.data(updatedList);
      } catch (e) {
        throw e;
      }
    }
  }

  bool isInWishlist(int designId) {
    // Synchronous check if data is available
    return state.value?.any((item) => item.designId == designId) ?? false;
  }
}
