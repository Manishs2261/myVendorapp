import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_code_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/products/domain/product_models.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/help/presentation/screens/help_feedback_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/products/presentation/screens/product_reviews_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/promotions/presentation/screens/promotions_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shop/presentation/screens/shop_profile_screen.dart';
import '../../features/shop/presentation/screens/shop_reviews_screen.dart';
import '../../features/shop/presentation/screens/storefront_editor_screen.dart';
import '../../features/products/presentation/screens/ai_preview_screen.dart';
import '../../features/products/presentation/screens/crop_editor_screen.dart';
import '../../features/products/presentation/screens/drafts_screen.dart';
import '../../features/sponsorship/presentation/screens/sponsorship_screen.dart';
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

      final goingToSplash = loc == RouteNames.splash;
      final goingToOnboarding = loc == RouteNames.onboarding;
      final goingToAuth = loc == RouteNames.login ||
          loc == RouteNames.register ||
          loc == RouteNames.forgotPassword ||
          loc == RouteNames.verifyCode ||
          loc == RouteNames.newPassword;

      // Stay on splash while either state is loading
      if (authLoading || onboardingLoading) {
        if (goingToAuth || goingToOnboarding) {
          return null;
        }
        return goingToSplash ? null : RouteNames.splash;
      }

      final loggedIn = authState.valueOrNull != null;
      final seenOnboarding = onboardingState.valueOrNull ?? false;

      // First-time user: must see onboarding
      if (!seenOnboarding && !goingToOnboarding && !goingToSplash) {
        return RouteNames.onboarding;
      }

      // Already authenticated: skip auth/onboarding screens
      if (loggedIn && (goingToAuth || goingToOnboarding || goingToSplash)) {
        return RouteNames.dashboard;
      }

      // Onboarding seen but not logged in: go to login
      if (seenOnboarding && !loggedIn && !goingToAuth && !goingToSplash) {
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
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyCode,
        builder: (_, state) => VerifyCodeScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: RouteNames.newPassword,
        builder: (_, state) => NewPasswordScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: RouteNames.aiPreview,
        builder: (_, state) =>
            AiPreviewScreen(initialFile: state.extra as XFile),
      ),
      GoRoute(
        path: RouteNames.cropEditor,
        builder: (_, state) =>
            CropEditorScreen(imageFile: state.extra as XFile),
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
            path: RouteNames.drafts,
            builder: (_, _) => const DraftsScreen(),
          ),
          GoRoute(
            path: '/products/:id',
            builder: (_, state) =>
                ProductDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/products/:id/edit',
            builder: (_, state) => AddProductScreen(
              initialProduct: state.extra as Product?,
            ),
          ),
          GoRoute(
            path: RouteNames.addProduct,
            builder: (_, _) => const AddProductScreen(),
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
          GoRoute(
            path: RouteNames.analytics,
            builder: (_, _) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: RouteNames.marketplace,
            builder: (_, _) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: RouteNames.promotions,
            builder: (_, _) => const PromotionsScreen(),
          ),
          GoRoute(
            path: RouteNames.sponsorship,
            builder: (_, _) => const SponsorshipScreen(),
          ),
          GoRoute(
            path: RouteNames.shopReviews,
            builder: (_, _) => const ShopReviewsScreen(),
          ),
          GoRoute(
            path: RouteNames.productReviews,
            builder: (_, _) => const ProductReviewsScreen(),
          ),
          GoRoute(
            path: RouteNames.helpFeedback,
            builder: (_, _) => const HelpFeedbackScreen(),
          ),
          GoRoute(
            path: RouteNames.storefrontEditor,
            builder: (_, _) => const StorefrontEditorScreen(),
          ),
          GoRoute(
            path: RouteNames.payments,
            builder: (_, _) => const PaymentsScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, _) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (_, _) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );

  ref.listen(authNotifierProvider, (_, _) => router.refresh());
  ref.listen(onboardingNotifierProvider, (_, _) => router.refresh());

  return router;
}
