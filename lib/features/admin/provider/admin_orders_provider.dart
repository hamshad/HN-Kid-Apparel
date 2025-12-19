import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/fancy_logger.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';
import 'admin_provider.dart';

final adminOrdersProvider =
    StateNotifierProvider<AdminOrdersNotifier, AsyncValue<List<AdminOrder>>>(
        (ref) {
  final adminService = ref.read(adminServiceProvider);
  return AdminOrdersNotifier(adminService);
});

final adminOrderStatsProvider = FutureProvider.autoDispose<OrderStatistics>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  // Watch adminOrdersProvider to refresh stats when orders change (optional but good UI)
  // Or at least when we toggle status? 
  // Actually, typically stats are global summary, so they might not change with filters, 
  // but they should refresh if we add/edit orders (not implemented yet).
  // For now, let's just fetch it once or on manual refresh.
  // To allow manual refresh, we can use ref.watch(refreshTriggerProvider) pattern or just invalidate.
  return adminService.getOrderStatistics();
});

class AdminOrdersNotifier extends StateNotifier<AsyncValue<List<AdminOrder>>> {
  final AdminService _adminService;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  String _currentStatus = 'pending';

  AdminOrdersNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    // If loading for the first time or refreshing, show loading
    // If loading more, we might want to keep the current data, but for simplicity we rely on AsyncValue
    // However, riverpod's AsyncValue handles 'loading more' gracefully if we use correct state transitions.
    // For this simple implementation:

    try {
      if (_currentPage == 1) {
        state = const AsyncValue.loading();
      }

      final newOrders = await _adminService.getAdminOrders(
        page: _currentPage,
        pageSize: _pageSize,
        status: _currentStatus,
      );

      if (newOrders.isEmpty) {
        _hasMore = false;
        if (_currentPage == 1) {
          state = const AsyncValue.data([]);
        }
      } else {
        if (_currentPage == 1) {
          state = AsyncValue.data(newOrders);
        } else {
          state.whenData((currentOrders) {
            state = AsyncValue.data([...currentOrders, ...newOrders]);
          });
        }
        // If we got less than requested, no more data
        if (newOrders.length < _pageSize) {
          _hasMore = false;
        } else {
            // Prepare for next page only if we got a full page? 
            // Or always increment? Usually if we get full page, we assume there might be more.
            // Let's just increment.
             _currentPage++;
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      FancyLogger.error('Error loading admin orders', e, st);
    }
  }

  Future<void> refresh() async {
    await loadOrders(refresh: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;
    await loadOrders();
  }

  String get currentStatus => _currentStatus;

  Future<void> updateStatus(String status) async {
    if (_currentStatus == status) return;
    _currentStatus = status;
    await refresh();
  }
}
