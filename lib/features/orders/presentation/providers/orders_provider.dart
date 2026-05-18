import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../data/orders_remote_source.dart';
import '../../data/orders_repository.dart';
import '../../domain/i_orders_repository.dart';
import '../../domain/order_models.dart';

part 'orders_provider.g.dart';

@riverpod
OrdersRemoteSource ordersRemoteSource(Ref ref) =>
    OrdersRemoteSource(ref.read(dioProvider));

@riverpod
IOrdersRepository ordersRepository(Ref ref) =>
    OrdersRepository(ref.read(ordersRemoteSourceProvider));

@riverpod
Future<PaginatedResponse<Order>> ordersList(
  Ref ref, {
  int page = 1,
  String? status,
}) =>
    ref.read(ordersRepositoryProvider).getOrders(page: page, status: status);

@riverpod
Future<Order> orderDetail(Ref ref, int id) =>
    ref.read(ordersRepositoryProvider).getOrder(id);
