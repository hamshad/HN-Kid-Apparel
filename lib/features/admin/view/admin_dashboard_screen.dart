import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/admin_orders_provider.dart';
import '../models/admin_models.dart';

import 'brand_list_screen.dart';
import 'category_list_screen.dart';
import 'series_list_screen.dart';
import 'design_list_screen.dart';
import 'size_list_screen.dart';
import 'product_size_price_list_screen.dart';
import 'user_list_screen.dart';
import 'profile_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Orders'),
              Tab(text: 'Brands'),
              Tab(text: 'Categories'),
              Tab(text: 'Series'),
              Tab(text: 'Products'),
              Tab(text: 'Sizes'),
              Tab(text: 'Prices'),
              Tab(text: 'Users'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _OrderList(),
            BrandListScreen(),
            CategoryListScreen(),
            SeriesListScreen(),
            DesignListScreen(),
            SizeListScreen(),
            ProductSizePriceListScreen(),
            UserManagementScreen(),
          ],
        ),
      ),
    );
  }
}

class _OrderStatsSummary extends ConsumerWidget {
  const _OrderStatsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsFuture = ref.watch(adminOrderStatsProvider);

    return statsFuture.when(
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard(
                        context,
                        'Total Revenue',
                        '₹${stats.totalRevenue.toStringAsFixed(2)}',
                        Icons.currency_rupee,
                        Colors.green,
                        isWide,
                      ),
                      _buildStatCard(
                        context,
                        'Total Orders',
                        '${stats.totalOrders}',
                        Icons.shopping_bag,
                        Colors.blue,
                        isWide,
                      ),
                      _buildStatCard(
                        context,
                        'Pending',
                        '${stats.pendingOrders}',
                        Icons.pending_actions,
                        Colors.orange,
                        isWide,
                      ),
                      _buildStatCard(
                        context,
                        'Items Sold',
                        '${stats.totalItemsSold}',
                        Icons.inventory_2,
                        Colors.purple,
                        isWide,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => SizedBox(
        height: 100,
        child: Center(child: Text('Error loading stats: $e')),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    MaterialColor color,
    bool isWide,
  ) {
    final width = isWide
        ? (MediaQuery.of(context).size.width - 32 - 48) / 4
        : (MediaQuery.of(context).size.width - 32 - 16) / 2;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(
              25,
            ), // Updated to use withAlpha (0-255)
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.shade50, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color.shade700),
              ),
              const Spacer(),
              if (title == 'Pending')
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends ConsumerStatefulWidget {
  const _OrderList();

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList> {
  final ScrollController _scrollController = ScrollController();
  bool _isOverviewExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // Collapse overview when scrolling down, expand when at top
      final shouldExpand = _scrollController.position.pixels <= 50;
      if (shouldExpand != _isOverviewExpanded) {
        setState(() {
          _isOverviewExpanded = shouldExpand;
        });
      }

      // Load more orders when near bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminOrdersProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersProvider);
    final notifier = ref.read(adminOrdersProvider.notifier);

    return Column(
      children: [
        // Collapsible Overview with smooth animation
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isOverviewExpanded
              ? const _OrderStatsSummary()
              : const SizedBox.shrink(),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'pending',
                    'processing',
                    'shipped',
                    'delivered',
                    'cancelled',
                  ].map((status) {
                    final isSelected = notifier.currentStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black87
                                : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) {
                            notifier.updateStatus(status);
                          }
                        },
                        selectedColor: _getStatusColor(status),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? _getStatusColor(status)
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        Expanded(
          child: state.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('No orders found'));
              }
              return RefreshIndicator(
                onRefresh: () => notifier.refresh(),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _EnhancedOrderCard(
                      order: order,
                      onApprove: () =>
                          _handleApprove(context, order.orderId, notifier),
                      onCancel: () =>
                          _handleCancel(context, order.orderId, notifier),
                      onShipped: () => _handleUpdateStatus(
                        context,
                        order.orderId,
                        'Shipped',
                        notifier,
                      ),
                      onDelivered: () => _handleUpdateStatus(
                        context,
                        order.orderId,
                        'Delivered',
                        notifier,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: SelectableText('Error: $e')),
          ),
        ),
      ],
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    int orderId,
    AdminOrdersNotifier notifier,
  ) async {
    try {
      await notifier.approveOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order approved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve order: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateStatus(
    BuildContext context,
    int orderId,
    String status,
    AdminOrdersNotifier notifier,
  ) async {
    try {
      await notifier.updateOrderStatus(orderId, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order marked as $status'),
            backgroundColor: status == 'Shipped' ? Colors.indigo : Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleCancel(
    BuildContext context,
    int orderId,
    AdminOrdersNotifier notifier,
  ) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for cancelling this order:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter cancellation reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await notifier.cancelOrder(orderId, reasonController.text.trim());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel order: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    reasonController.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'processing':
        return Colors.blue.shade100;
      case 'shipped':
        return Colors.indigo.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}

class _EnhancedOrderCard extends StatelessWidget {
  final AdminOrder order;
  final VoidCallback onApprove;
  final VoidCallback onCancel;
  final VoidCallback? onShipped;
  final VoidCallback? onDelivered;

  const _EnhancedOrderCard({
    required this.order,
    required this.onApprove,
    required this.onCancel,
    this.onShipped,
    this.onDelivered,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.status.toLowerCase() == 'pending';
    final isProcessing = order.status.toLowerCase() == 'processing';
    final isShipped = order.status.toLowerCase() == 'shipped';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getStatusBorderColor(order.status),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withAlpha(50),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusBorderColor(order.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(order.status),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(order.orderDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${order.totalQty} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Customer Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.userName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.userMobile,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (order.orderItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Products Section
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...order.orderItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Product Image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: item.designImageUrl.isNotEmpty
                                ? Image.network(
                                    item.designImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons.image,
                                    color: Colors.grey.shade400,
                                  ),
                          ),
                          const SizedBox(width: 12),

                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.designName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${item.totalQuantity}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.sizeDetails.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: item.sizeDetails.map((size) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          '${size.sizeName}: ${size.orderedQty}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons (only for pending orders)
          if (isPending) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Shipped button for Processing orders
          if (isProcessing && onShipped != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShipped,
                  icon: const Icon(Icons.local_shipping, size: 20),
                  label: const Text('Mark as Shipped'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],

          // Delivered button for Shipped orders
          if (isShipped && onDelivered != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDelivered,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Mark as Delivered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'processing':
        return Colors.blue.shade100;
      case 'shipped':
        return Colors.indigo.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade300;
      case 'processing':
        return Colors.blue.shade300;
      case 'shipped':
        return Colors.indigo.shade300;
      case 'delivered':
        return Colors.green.shade300;
      case 'cancelled':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade900;
      case 'processing':
        return Colors.blue.shade900;
      case 'shipped':
        return Colors.indigo.shade900;
      case 'delivered':
        return Colors.green.shade900;
      case 'cancelled':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade900;
    }
  }
}
