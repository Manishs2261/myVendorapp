import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(int.parse(id)));

    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (product) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (product.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: Image.network(
                  product.imageUrls.first,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(AppFormatters.currency(product.price)),
            const SizedBox(height: 8),
            StatusBadge(status: product.status.name),
            const SizedBox(height: 16),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}
