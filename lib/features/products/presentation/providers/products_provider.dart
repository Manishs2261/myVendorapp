import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../data/products_remote_source.dart';
import '../../data/products_repository.dart';
import '../../domain/i_products_repository.dart';
import '../../domain/product_models.dart';

part 'products_provider.g.dart';

@riverpod
ProductsRemoteSource productsRemoteSource(Ref ref) =>
    ProductsRemoteSource(ref.read(dioProvider));

@riverpod
IProductsRepository productsRepository(Ref ref) =>
    ProductsRepository(ref.read(productsRemoteSourceProvider));

@riverpod
Future<PaginatedResponse<Product>> productsList(
  Ref ref, {
  int page = 1,
  int limit = 20,
  String? search,
  String? status,
  int? categoryId,
  String? stockFilter,
  String sortBy = 'recent',
  bool discountOnly = false,
  double? minPrice,
  double? maxPrice,
  int? minStock,
  int? maxStock,
}) =>
    ref.read(productsRepositoryProvider).getProducts(
          page: page,
          limit: limit,
          search: search,
          status: status,
          categoryId: categoryId,
          stockFilter: stockFilter,
          sortBy: sortBy,
          discountOnly: discountOnly,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minStock: minStock,
          maxStock: maxStock,
        );

@riverpod
Future<int> inactiveCount(Ref ref) async {
  final res = await ref
      .read(productsRepositoryProvider)
      .getProducts(status: 'inactive', limit: 1);
  return res.total;
}

@riverpod
Future<Product> productDetail(Ref ref, int id) =>
    ref.read(productsRepositoryProvider).getProduct(id);

// Manual provider — no code generation needed
final categoriesProvider = FutureProvider<List<Category>>((ref) =>
    ref.read(productsRepositoryProvider).getCategories());
