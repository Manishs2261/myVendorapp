import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/products/domain/i_products_repository.dart';
import '../../../../features/products/domain/product_models.dart';
import '../../../../features/products/presentation/providers/products_provider.dart';

class PromotionsState {
  final List<Product> products;
  final bool loading;
  final String? error;
  final Set<int> requestingIds;

  const PromotionsState({
    this.products = const [],
    this.loading = false,
    this.error,
    this.requestingIds = const {},
  });

  PromotionsState copyWith({
    List<Product>? products,
    bool? loading,
    String? error,
    Set<int>? requestingIds,
    bool clearError = false,
  }) =>
      PromotionsState(
        products: products ?? this.products,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        requestingIds: requestingIds ?? this.requestingIds,
      );

  int get activeCount => products.where((p) => p.isSponsored).length;
  int get pendingCount =>
      products.where((p) => p.sponsorStatus == 'pending').length;
  int get rejectedCount =>
      products.where((p) => p.sponsorStatus == 'rejected').length;
  int get canRequestCount =>
      products.where((p) => p.sponsorStatus == 'none' && !p.isSponsored).length;
}

class PromotionsNotifier extends StateNotifier<PromotionsState> {
  final IProductsRepository _repository;

  PromotionsNotifier(this._repository) : super(const PromotionsState());

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final page = await _repository.getProducts(limit: 100, sortBy: 'recent');
      state = state.copyWith(loading: false, products: page.data);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> requestSponsorship(int productId) async {
    final ids = {...state.requestingIds, productId};
    state = state.copyWith(requestingIds: ids);
    try {
      await _repository.requestSponsorship(productId);
      final updated = state.products.map((p) {
        if (p.id == productId) {
          return Product(
            id: p.id,
            name: p.name,
            description: p.description,
            price: p.price,
            originalPrice: p.originalPrice,
            discountPercentage: p.discountPercentage,
            stock: p.stock,
            status: p.status,
            imageUrls: p.imageUrls,
            categoryId: p.categoryId,
            category: p.category,
            brand: p.brand,
            unit: p.unit,
            tags: p.tags,
            specifications: p.specifications,
            colorVariations: p.colorVariations,
            latitude: p.latitude,
            longitude: p.longitude,
            viewCount: p.viewCount,
            isSponsored: p.isSponsored,
            sponsorStatus: 'pending',
            isFeatured: p.isFeatured,
            rating: p.rating,
            reviewCount: p.reviewCount,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
          );
        }
        return p;
      }).toList();
      final newIds = {...state.requestingIds}..remove(productId);
      state = state.copyWith(products: updated, requestingIds: newIds);
      return true;
    } catch (e) {
      final newIds = {...state.requestingIds}..remove(productId);
      state = state.copyWith(requestingIds: newIds, error: e.toString());
      return false;
    }
  }
}

final promotionsProvider =
    StateNotifierProvider<PromotionsNotifier, PromotionsState>(
  (ref) => PromotionsNotifier(ref.read(productsRepositoryProvider)),
);
