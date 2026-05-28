import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';

class PendingAction {
  final String id;
  final String method;
  final String endpoint;
  final Map<String, dynamic>? body;
  final int createdAt;

  const PendingAction({
    required this.id,
    required this.method,
    required this.endpoint,
    this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'endpoint': endpoint,
        'body': body,
        'createdAt': createdAt,
      };

  factory PendingAction.fromJson(Map<String, dynamic> json) => PendingAction(
        id: json['id'] as String,
        method: json['method'] as String,
        endpoint: json['endpoint'] as String,
        body: json['body'] != null
            ? Map<String, dynamic>.from(json['body'] as Map)
            : null,
        createdAt: json['createdAt'] as int,
      );
}

class OfflineQueueService {
  static const _boxName = 'offline_queue';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> enqueue(PendingAction action) async {
    await _box.put(action.id, action.toJson());
    AppLogger.debug('Queued offline action: ${action.method} ${action.endpoint}');
  }

  List<PendingAction> getAll() {
    return _box.values
        .map((e) => PendingAction.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> remove(String id) => _box.delete(id);

  bool get hasPending => _box.isNotEmpty;

  Future<void> processAll(Dio dio) async {
    final actions = getAll();
    for (final action in actions) {
      try {
        await _execute(dio, action);
        await remove(action.id);
        AppLogger.debug('Processed queued action: ${action.method} ${action.endpoint}');
      } catch (e) {
        AppLogger.warning('Failed to process queued action ${action.id}: $e');
      }
    }
  }

  Future<void> _execute(Dio dio, PendingAction action) async {
    switch (action.method.toUpperCase()) {
      case 'PUT':
        await dio.put(action.endpoint, data: action.body);
      case 'POST':
        await dio.post(action.endpoint, data: action.body);
      case 'DELETE':
        await dio.delete(action.endpoint);
      case 'PATCH':
        await dio.patch(action.endpoint, data: action.body);
    }
  }
}
