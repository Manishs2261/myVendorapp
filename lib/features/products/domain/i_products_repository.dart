import '../../../shared/models/paginated_response.dart';
import 'product_models.dart';

abstract class IProductsRepository {
  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    bool? isDraft,
    int? categoryId,
    String? stockFilter,
    String sortBy = 'recent',
    bool discountOnly = false,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
  });
  Future<Product> getProduct(int id);
  Future<Product> createProduct(ProductForm form);
  Future<Product> updateProduct(int id, ProductForm form);
  Future<void> deleteProduct(int id);
  Future<List<Category>> getCategories();
  Future<void> requestSponsorship(int productId);
  Future<Product> publishDraft(int id);
}
