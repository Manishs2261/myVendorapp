import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/cache/cache_service.dart';
import 'core/cache/offline_queue.dart';
import 'core/config/app_config.dart';
import 'core/providers/cache_providers.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/app_logger.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'firebase_options.dart';

void main() => bootstrap(AppFlavor.prod);

Future<void> bootstrap(AppFlavor flavor) async {
  AppConfig.initialize(flavor);
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize();

  await Hive.initFlutter();
  final cacheService = CacheService();
  await cacheService.init();
  final offlineQueue = OfflineQueueService();
  await offlineQueue.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.initialize();

  runApp(
    AppStateContainer(
      cacheService: cacheService,
      offlineQueue: offlineQueue,
      child: const MyShopVendorApp(),
    ),
  );
}

class AppStateContainer extends StatefulWidget {
  final Widget child;
  final CacheService cacheService;
  final OfflineQueueService offlineQueue;

  const AppStateContainer({
    super.key,
    required this.child,
    required this.cacheService,
    required this.offlineQueue,
  });

  static AppStateContainerState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateContainerState>();
  }

  @override
  AppStateContainerState createState() => AppStateContainerState();
}

class AppStateContainerState extends State<AppStateContainer> {
  Key _key = UniqueKey();

  void resetScope() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_key),
      child: ProviderScope(
        key: _key,
        overrides: [
          cacheServiceProvider.overrideWithValue(widget.cacheService),
          offlineQueueProvider.overrideWithValue(widget.offlineQueue),
        ],
        child: widget.child,
      ),
    );
  }
}

class MyShopVendorApp extends ConsumerStatefulWidget {
  const MyShopVendorApp({super.key});

  @override
  ConsumerState<MyShopVendorApp> createState() => _MyShopVendorAppState();
}

class _MyShopVendorAppState extends ConsumerState<MyShopVendorApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FcmService.onNewMessage = _onNewMessage;
    FcmService.onNotificationTap = _onNotificationTap;
// Handle notification tap when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(appRouterProvider).go(RouteNames.notifications);
        });
      }
    });
  }

  void _onNewMessage() {
    ref.invalidate(notificationsNotifierProvider);
  }

  void _onNotificationTap() {
    ref.read(appRouterProvider).go(RouteNames.notifications);
  }

  @override
  void didChangePlatformBrightness() {
    // Re-resolve system brightness in case the preference is ThemeMode.system.
    ref.invalidate(isDarkModeProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FcmService.onNewMessage = null;
    FcmService.onNotificationTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider).valueOrNull ?? ThemeMode.system;
    ref.watch(isDarkModeProvider); // keeps AppColors in sync before descendants build
    return MaterialApp.router(
      title: 'My Shop Seller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
