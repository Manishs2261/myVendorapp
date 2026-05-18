import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/products_provider.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider());

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('${RouteNames.products}/new'),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(productsListProvider()),
        ),
        data: (page) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(productsListProvider()),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: page.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final product = page.data[i];
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(AppFormatters.currency(product.price)),
                  trailing: StatusBadge(status: product.status.name),
                  onTap: () => context.push(
                    RouteNames.productDetailPath(product.id.toString()),
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
