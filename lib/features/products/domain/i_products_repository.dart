import '../../../shared/models/paginated_response.dart';
import 'product_models.dart';

abstract class IProductsRepository {
  Future<PaginatedResponse<Product>> getProducts({int page = 1, String? status});
  Future<Product> getProduct(int id);
  Future<Product> createProduct(ProductForm form);
  Future<Product> updateProduct(int id, ProductForm form);
  Future<void> deleteProduct(int id);
}
