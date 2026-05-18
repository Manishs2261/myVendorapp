enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productName: json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String customerName;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.items,
    required this.createdAt,
    required this.customerName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      customerName: json['customer_name'] as String? ?? '',
    );
  }
}
