import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/last_updated_chip.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/orders_provider.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersNotifierProvider);
    final notifier = ref.read(ordersNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          LastUpdatedChip(
            lastUpdated: notifier.lastUpdated,
            isRefreshing: ordersAsync.isLoading,
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const ShimmerList(count: 7, itemHeight: 72),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => notifier.refresh(),
        ),
        data: (page) => RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: page.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final order = page.data[i];
              return Card(
                child: ListTile(
                  title: Text('#${order.orderNumber}'),
                  subtitle: Text(
                    '${order.customerName} • ${AppFormatters.date(order.createdAt)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppFormatters.currency(order.total)),
                      const SizedBox(width: 8),
                      StatusBadge(status: order.status.name),
                    ],
                  ),
                  onTap: () => context.push(
                    RouteNames.orderDetailPath(order.id.toString()),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
