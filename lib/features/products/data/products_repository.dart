import 'package:image_picker/image_picker.dart';

import '../../../core/utils/json_parser.dart';
import '../../../shared/models/paginated_response.dart';
import '../domain/i_products_repository.dart';
import '../domain/product_models.dart';
import 'products_remote_source.dart';

class ProductsRepository implements IProductsRepository {
  final ProductsRemoteSource _remote;
  ProductsRepository(this._remote);

  @override
  Future<PaginatedResponse<Product>> getProducts({
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
  }) async {
    final data = await _remote.getProducts(
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
    return parseJson(
      'PaginatedResponse<Product>',
      data,
      (json) => PaginatedResponse.fromJson(json, Product.fromJson),
    );
  }

  @override
  Future<Product> getProduct(int id) async {
    final data = await _remote.getProduct(id);
    return parseJson('Product', data, Product.fromJson);
  }

  @override
  Future<Product> createProduct(ProductForm form) async {
    final data = await _remote.createProduct(form.toJson());
    return parseJson('Product', data, Product.fromJson);
  }

  Future<Product> createProductMultipart({
    required ProductForm form,
    required List<XFile> images,
    XFile? video,
  }) async {
    final data = await _remote.createProductMultipart(
      data: form.toJson(),
      images: images,
      video: video,
    );
    return parseJson('Product', data, Product.fromJson);
  }

  @override
  Future<Product> updateProduct(int id, ProductForm form) async {
    final data = await _remote.updateProduct(id, form.toJson());
    return parseJson('Product', data, Product.fromJson);
  }

  @override
  Future<void> deleteProduct(int id) => _remote.deleteProduct(id);

  @override
  Future<void> requestSponsorship(int productId) =>
      _remote.requestSponsorship(productId);

  @override
  Future<List<Category>> getCategories() async {
    final data = await _remote.getCategories();
    return data
        .map((e) => parseJson(
            'Category', e as Map<String, dynamic>, Category.fromJson))
        .toList();
  }
}
