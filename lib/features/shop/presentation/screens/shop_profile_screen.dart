import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/shop_provider.dart';

class ShopProfileScreen extends ConsumerWidget {
  const ShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('My Shop'),
      ),
      body: shopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(shopNotifierProvider),
        ),
        data: (shop) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (shop.bannerUrl != null)
              SizedBox(
                height: 160,
                child: Image.network(shop.bannerUrl!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (shop.logoUrl != null)
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(shop.logoUrl!),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.businessName,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      StatusBadge(status: shop.status),
                    ],
                  ),
                ),
              ],
            ),
            if (shop.description != null) ...[
              const SizedBox(height: 16),
              Text(shop.description!),
            ],
          ],
        ),
      ),
    );
  }
}
