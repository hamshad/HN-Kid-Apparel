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
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
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

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, MaterialColor color, bool isWide) {
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
            color: Colors.grey.withAlpha(25), // Updated to use withAlpha (0-255)
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
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminOrdersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersProvider);
    final notifier = ref.read(adminOrdersProvider.notifier);

    return Column(
      children: [
        const _OrderStatsSummary(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'pending',
                'processing',
                'shipped',
                'delivered',
                'cancelled'
              ].map((status) {
                final isSelected = notifier.currentStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      child: ExpansionTile(
                        title: Text(order.orderNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('User: ${order.userName}'),
                            Text('Mobile: ${order.userMobile}'),
                            Text('Date: ${order.orderDate.toString().split('.')[0]}'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(label: Text('Qty: ${order.totalQty}')),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(order.status),
                                  backgroundColor: _getStatusColor(order.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: order.orderItems.map((item) {
                          return ListTile(
                            leading: item.designImageUrl.isNotEmpty
                                ? Image.network(item.designImageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) =>
                                        const Icon(Icons.image_not_supported))
                                : const Icon(Icons.image),
                            title: Text(item.designName),
                            subtitle: Text(
                                'Qty: ${item.totalQuantity} | Size: ${item.sizeDetails.map((e) => e.sizeName).join(', ')}'),
                          );
                        }).toList(),
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

