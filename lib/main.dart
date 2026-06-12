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
    ProviderScope(
      overrides: [
        cacheServiceProvider.overrideWithValue(cacheService),
        offlineQueueProvider.overrideWithValue(offlineQueue),
      ],
      child: const LuminaVendorApp(),
    ),
  );
}

class LuminaVendorApp extends ConsumerStatefulWidget {
  const LuminaVendorApp({super.key});

  @override
  ConsumerState<LuminaVendorApp> createState() => _LuminaVendorAppState();
}

class _LuminaVendorAppState extends ConsumerState<LuminaVendorApp> {
  @override
  void initState() {
    super.initState();
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
  void dispose() {
    FcmService.onNewMessage = null;
    FcmService.onNotificationTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'My Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
