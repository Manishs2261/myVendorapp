import '../../../core/utils/json_parser.dart';
import '../../../shared/models/paginated_response.dart';
import '../domain/i_orders_repository.dart';
import '../domain/order_models.dart';
import 'orders_remote_source.dart';

class OrdersRepository implements IOrdersRepository {
  final OrdersRemoteSource _remote;
  OrdersRepository(this._remote);

  @override
  Future<PaginatedResponse<Order>> getOrders({
    int page = 1,
    String? status,
  }) async {
    final data = await _remote.getOrders(page: page, status: status);
    return parseJson(
      'PaginatedResponse<Order>',
      data,
      (json) => PaginatedResponse.fromJson(json, Order.fromJson),
    );
  }

  @override
  Future<Order> getOrder(int id) async {
    final data = await _remote.getOrder(id);
    return parseJson('Order', data, Order.fromJson);
  }

  @override
  Future<Order> updateStatus(int id, OrderStatus status) async {
    final data = await _remote.updateStatus(id, status.name);
    return parseJson('Order', data, Order.fromJson);
  }
}
