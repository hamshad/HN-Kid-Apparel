import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/catalog/view/catalog_screen.dart';
import '../../features/catalog/view/home_screen.dart';
import '../../features/product_detail/view/product_detail_screen.dart';
import '../../features/cart/view/cart_screen.dart';
import '../../features/orders/view/orders_screen.dart';
import '../../features/admin/view/admin_dashboard_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    name: 'product_detail',
                    parentNavigatorKey: rootNavigatorKey, // Hide bottom nav
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ProductDetailScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Branch 1: Catalog
           StatefulShellBranch(
             routes: [
                GoRoute(
                 path: '/tab-catalog', 
                 name: 'catalog',
                 builder: (context, state) {
                   final category = state.uri.queryParameters['category'];
                   return CatalogScreen(initialCategory: category);
                 },
               ),
             ],
           ),

          // Branch 2: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),

          // Branch 3: Admin
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Full screen routes
      GoRoute(
        path: '/cart',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(body: Center(child: Text("Login Screen"))),
      ),
    ],
  );
});
