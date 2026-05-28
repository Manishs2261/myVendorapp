import 'package:flutter/material.dart';

class LastUpdatedChip extends StatelessWidget {
  final DateTime? lastUpdated;
  final bool isRefreshing;

  const LastUpdatedChip({
    super.key,
    required this.lastUpdated,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isRefreshing) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            SizedBox(width: 4),
            Text('Updating…', style: TextStyle(fontSize: 11)),
          ],
        ),
      );
    }

    if (lastUpdated == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        _label(lastUpdated!),
        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
      ),
    );
  }

  String _label(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just updated';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}
