import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shop/presentation/screens/shop_profile_screen.dart';
import '../widgets/main_shell.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  late final GoRouter router;

  router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final onboardingState = ref.read(onboardingNotifierProvider);
      final loc = state.matchedLocation;

      final authLoading = authState.isLoading;
      final onboardingLoading = onboardingState.isLoading;

      // Stay on splash while either state is loading
      if (authLoading || onboardingLoading) {
        return loc == RouteNames.splash ? null : RouteNames.splash;
      }

      final loggedIn = authState.valueOrNull != null;
      final seenOnboarding = onboardingState.valueOrNull ?? false;

      final goingToSplash = loc == RouteNames.splash;
      final goingToOnboarding = loc == RouteNames.onboarding;
      final goingToAuth =
          loc == RouteNames.login || loc == RouteNames.register;

      // First-time user: must see onboarding
      if (!seenOnboarding && !goingToOnboarding && !goingToSplash) {
        return RouteNames.onboarding;
      }

      // Already authenticated: skip auth/onboarding screens
      if (loggedIn && (goingToAuth || goingToOnboarding || goingToSplash)) {
        return RouteNames.dashboard;
      }

      // Onboarding seen but not logged in: go to login
      if (seenOnboarding && !loggedIn && !goingToAuth) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
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

  ref.listen(authNotifierProvider, (_, _) => router.refresh());
  ref.listen(onboardingNotifierProvider, (_, _) => router.refresh());

  return router;
}
