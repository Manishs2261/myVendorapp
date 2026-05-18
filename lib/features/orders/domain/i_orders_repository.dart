import '../../../shared/models/paginated_response.dart';
import 'order_models.dart';

abstract class IOrdersRepository {
  Future<PaginatedResponse<Order>> getOrders({int page = 1, String? status});
  Future<Order> getOrder(int id);
  Future<Order> updateStatus(int id, OrderStatus status);
}
