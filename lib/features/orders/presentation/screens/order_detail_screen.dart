import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(int.parse(id)));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleLarge),
                StatusBadge(status: order.status.name),
              ],
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order.customerName}'),
            Text('Date: ${AppFormatters.date(order.createdAt)}'),
            const Divider(height: 32),
            ...order.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text(AppFormatters.currency(item.subtotal)),
                )),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(AppFormatters.currency(order.total),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
