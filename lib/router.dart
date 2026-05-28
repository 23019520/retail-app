import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/route_constants.dart';
import 'features/auth/providers/auth_provider.dart';

// --- Screen imports (Sprint 1: placeholders; replaced sprint-by-sprint) ---
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/catalog/screens/home_screen.dart';
import 'features/catalog/screens/product_list_screen.dart';
import 'features/catalog/screens/product_detail_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/cart/screens/checkout_screen.dart';
import 'features/cart/screens/order_success_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/orders/screens/order_detail_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/admin/screens/admin_login_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/product_management_screen.dart';
import 'features/admin/screens/product_form_screen.dart';
import 'features/admin/screens/order_management_screen.dart';
import 'features/admin/screens/order_detail_admin_screen.dart';
import 'features/admin/screens/settings_screen.dart';
import 'features/admin/widgets/admin_nav_rail.dart';

/// Riverpod provider so the router can watch auth state reactively.
/// When authStateProvider changes, go_router re-runs the redirect.
final routerProvider = Provider<GoRouter>((ref) {
  // listenable that fires when auth state changes
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    refreshListenable: authListenable,
    debugLogDiagnostics: true, // turn off in production

    // --- Route guard ---
    redirect: (BuildContext context, GoRouterState state) {
      final authValue = ref.read(authStateProvider);
      final isLoading = authValue.isLoading;
      final isLoggedIn = authValue.value != null;
      final location = state.matchedLocation;

      // Stay on splash while Firebase auth initialises
      if (isLoading) return RouteConstants.splash;

      final isOnAuthPage = location == RouteConstants.login ||
          location == RouteConstants.register ||
          location == RouteConstants.splash;


      // Not logged in → force to login (except auth pages)
      if (!isLoggedIn && !isOnAuthPage) return RouteConstants.login;

      // Logged in and on auth page → go home
      if (isLoggedIn && isOnAuthPage) return RouteConstants.home;

      // Admin route guard is handled inside AdminLoginScreen / admin screens
      return null; // no redirect needed
    },

    routes: [
      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Customer shell with bottom nav ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _CustomerShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteConstants.productList,
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: RouteConstants.productDetail,
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['productId'] ?? '',
            ),
          ),
          GoRoute(
            path: RouteConstants.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteConstants.orderHistory,
            builder: (context, state) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: RouteConstants.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Checkout flow (no bottom nav) ─────────────────────────────────
      GoRoute(
        path: RouteConstants.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteConstants.orderSuccess,
        builder: (context, state) => OrderSuccessScreen(
          orderId: state.uri.queryParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteConstants.orderDetail,
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),

      // ── Admin ─────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.adminLogin,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShellScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminProducts,
            builder: (context, state) => const ProductManagementScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminProductForm,
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminOrders,
            builder: (context, state) => const OrderManagementScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminOrderDetail,
            builder: (context, state) => OrderDetailAdminScreen(
              orderId: state.pathParameters['orderId'] ?? '',
            ),
          ),
          GoRoute(
            path: RouteConstants.adminSettings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// ── Customer shell widget ──────────────────────────────────────────────────
class _CustomerShell extends StatefulWidget {
  const _CustomerShell({required this.child});
  final Widget child;

  @override
  State<_CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<_CustomerShell> {
  int _selectedIndex = 0;

  final _tabs = [
    RouteConstants.home,
    RouteConstants.productList,
    RouteConstants.cart,
    RouteConstants.orderHistory,
    RouteConstants.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_tabs[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Auth listenable (bridges Riverpod → go_router) ────────────────────────
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
