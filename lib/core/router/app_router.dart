import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shop/presentation/screens/shop_profile_screen.dart';
import '../widgets/main_shell.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.dashboard,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loggedIn = authState.valueOrNull != null;
      final loading = authState.isLoading;
      final goingToAuth = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;

      if (loading) return null;
      if (!loggedIn && !goingToAuth) return RouteNames.login;
      if (loggedIn && goingToAuth) return RouteNames.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.products,
            builder: (_, _) => const ProductsListScreen(),
          ),
          GoRoute(
            path: '/products/:id',
            builder: (_, state) =>
                ProductDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.orders,
            builder: (_, _) => const OrdersListScreen(),
          ),
          GoRoute(
            path: '/orders/:id',
            builder: (_, state) =>
                OrderDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.shop,
            builder: (_, _) => const ShopProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
