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
  String? status,
}) =>
    ref
        .read(productsRepositoryProvider)
        .getProducts(page: page, status: status);

@riverpod
Future<Product> productDetail(Ref ref, int id) =>
    ref.read(productsRepositoryProvider).getProduct(id);

// Manual provider — no code generation needed
final categoriesProvider = FutureProvider<List<Category>>((ref) =>
    ref.read(productsRepositoryProvider).getCategories());
