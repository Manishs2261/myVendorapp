import 'package:flutter/material.dart';

enum FeedbackType {
  feedback,
  bugReport,
  featureRequest,
  general;

  static FeedbackType fromString(String value) => switch (value) {
        'feedback' => FeedbackType.feedback,
        'bug_report' => FeedbackType.bugReport,
        'feature_request' => FeedbackType.featureRequest,
        _ => FeedbackType.general,
      };

  String get apiValue => switch (this) {
        FeedbackType.feedback => 'feedback',
        FeedbackType.bugReport => 'bug_report',
        FeedbackType.featureRequest => 'feature_request',
        FeedbackType.general => 'general',
      };

  String get label => switch (this) {
        FeedbackType.feedback => 'Feedback',
        FeedbackType.bugReport => 'Bug Report',
        FeedbackType.featureRequest => 'Feature Request',
        FeedbackType.general => 'General',
      };

  IconData get icon => switch (this) {
        FeedbackType.feedback => Icons.chat_bubble_outline,
        FeedbackType.bugReport => Icons.bug_report_outlined,
        FeedbackType.featureRequest => Icons.lightbulb_outline,
        FeedbackType.general => Icons.help_outline,
      };

  Color get color => switch (this) {
        FeedbackType.feedback => const Color(0xFF3B82F6),
        FeedbackType.bugReport => const Color(0xFFEF4444),
        FeedbackType.featureRequest => const Color(0xFFF59E0B),
        FeedbackType.general => const Color(0xFF6B7280),
      };
}

enum FeedbackPriority {
  low,
  medium,
  high;

  static FeedbackPriority fromString(String value) => switch (value) {
        'low' => FeedbackPriority.low,
        'high' => FeedbackPriority.high,
        _ => FeedbackPriority.medium,
      };

  String get label => switch (this) {
        FeedbackPriority.low => 'Low',
        FeedbackPriority.medium => 'Medium',
        FeedbackPriority.high => 'High',
      };

  Color get color => switch (this) {
        FeedbackPriority.low => const Color(0xFF6B7280),
        FeedbackPriority.medium => const Color(0xFFF59E0B),
        FeedbackPriority.high => const Color(0xFFEF4444),
      };
}

enum FeedbackStatus {
  open,
  inProgress,
  resolved,
  closed;

  static FeedbackStatus fromString(String value) => switch (value) {
        'open' => FeedbackStatus.open,
        'in_progress' => FeedbackStatus.inProgress,
        'resolved' => FeedbackStatus.resolved,
        'closed' => FeedbackStatus.closed,
        _ => FeedbackStatus.open,
      };

  String get apiValue => switch (this) {
        FeedbackStatus.open => 'open',
        FeedbackStatus.inProgress => 'in_progress',
        FeedbackStatus.resolved => 'resolved',
        FeedbackStatus.closed => 'closed',
      };

  String get label => switch (this) {
        FeedbackStatus.open => 'Open',
        FeedbackStatus.inProgress => 'In Progress',
        FeedbackStatus.resolved => 'Resolved',
        FeedbackStatus.closed => 'Closed',
      };

  Color get color => switch (this) {
        FeedbackStatus.open => const Color(0xFF3B82F6),
        FeedbackStatus.inProgress => const Color(0xFFF59E0B),
        FeedbackStatus.resolved => const Color(0xFF10B981),
        FeedbackStatus.closed => const Color(0xFF6B7280),
      };
}

class FeedbackItem {
  final int id;
  final int vendorId;
  final FeedbackType type;
  final String subject;
  final String description;
  final FeedbackStatus status;
  final FeedbackPriority priority;
  final String? adminResponse;
  final DateTime? adminResponseAt;
  final DateTime createdAt;

  const FeedbackItem({
    required this.id,
    required this.vendorId,
    required this.type,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    this.adminResponse,
    this.adminResponseAt,
    required this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      type: FeedbackType.fromString(json['type'] as String? ?? 'general'),
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: FeedbackStatus.fromString(json['status'] as String? ?? 'open'),
      priority: FeedbackPriority.fromString(json['priority'] as String? ?? 'medium'),
      adminResponse: json['admin_response'] as String?,
      adminResponseAt: json['admin_response_at'] != null
          ? DateTime.parse(json['admin_response_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class FeedbackCreate {
  final FeedbackType type;
  final String subject;
  final String description;
  final FeedbackPriority priority;

  const FeedbackCreate({
    required this.type,
    required this.subject,
    required this.description,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'type': type.apiValue,
        'subject': subject,
        'description': description,
        'priority': priority.name,
      };
}
