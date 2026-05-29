import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status.toLowerCase()) {
      'approved' || 'active' || 'delivered' => ('Active', Colors.green),
      'pending' => ('Pending', Colors.orange),
      'suspended' || 'rejected' || 'cancelled' => ('Rejected', Colors.red),
      'processing' => ('Processing', Colors.blue),
      'draft' => ('Draft', Colors.blue),
      'outofstock' || 'out_of_stock' => ('Out of Stock', Colors.orange),
      _ => (status, Colors.grey),
    };

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
