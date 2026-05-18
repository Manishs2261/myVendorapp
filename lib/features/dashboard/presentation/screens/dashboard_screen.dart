import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardOverviewProvider),
        ),
        data: (overview) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardOverviewProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: 'Total Revenue',
                    value: AppFormatters.currency(overview.totalRevenue),
                    icon: Icons.currency_rupee,
                  ),
                  StatCard(
                    label: 'Total Orders',
                    value: overview.totalOrders.toString(),
                    icon: Icons.shopping_bag_outlined,
                  ),
                  StatCard(
                    label: 'Products',
                    value: overview.totalProducts.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                  StatCard(
                    label: 'Pending Orders',
                    value: overview.pendingOrders.toString(),
                    icon: Icons.pending_actions_outlined,
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
