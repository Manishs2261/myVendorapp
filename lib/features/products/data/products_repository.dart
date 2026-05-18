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
    String? status,
  }) async {
    final data = await _remote.getProducts(page: page, status: status);
    return PaginatedResponse.fromJson(data, Product.fromJson);
  }

  @override
  Future<Product> getProduct(int id) async {
    final data = await _remote.getProduct(id);
    return Product.fromJson(data);
  }

  @override
  Future<Product> createProduct(ProductForm form) async {
    final data = await _remote.createProduct(form.toJson());
    return Product.fromJson(data);
  }

  @override
  Future<Product> updateProduct(int id, ProductForm form) async {
    final data = await _remote.updateProduct(id, form.toJson());
    return Product.fromJson(data);
  }

  @override
  Future<void> deleteProduct(int id) => _remote.deleteProduct(id);
}
