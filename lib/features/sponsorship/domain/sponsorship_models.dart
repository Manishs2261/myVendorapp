class SponsorshipPlan {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final int priority;
  final int maxCategories;
  final int maxLocations;
  final bool isActive;

  const SponsorshipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.priority,
    required this.maxCategories,
    required this.maxLocations,
    required this.isActive,
  });

  double get pricePerDay => durationDays > 0 ? price / durationDays : 0;

  factory SponsorshipPlan.fromJson(Map<String, dynamic> j) => SponsorshipPlan(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        durationDays: (j['duration_days'] as num?)?.toInt() ?? 30,
        priority: (j['priority'] as num?)?.toInt() ?? 1,
        maxCategories: (j['max_categories'] as num?)?.toInt() ?? 3,
        maxLocations: (j['max_locations'] as num?)?.toInt() ?? 3,
        isActive: j['is_active'] as bool? ?? true,
      );
}

class SponsorshipApplication {
  final int id;
  final int vendorId;
  final int planId;
  final String status;
  final List<int> targetCategories;
  final List<String> targetLocations;
  final List<String> targetKeywords;
  final int priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final int clickCount;
  final int viewCount;
  final String? adminNotes;
  final DateTime? createdAt;
  final SponsorshipPlan? plan;

  const SponsorshipApplication({
    required this.id,
    required this.vendorId,
    required this.planId,
    required this.status,
    required this.targetCategories,
    required this.targetLocations,
    required this.targetKeywords,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.clickCount,
    required this.viewCount,
    this.adminNotes,
    this.createdAt,
    this.plan,
  });

  bool get isActive => status == 'active' || status == 'approved';

  double get ctr =>
      viewCount > 0 ? (clickCount / viewCount * 100).clamp(0, 100) : 0.0;

  int get daysLeft {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays.clamp(0, 9999);
  }

  int get daysElapsed {
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate!).inDays.clamp(0, 9999);
  }

  int get totalDays => plan?.durationDays ?? 30;

  double get progressFraction {
    if (startDate == null || endDate == null) return 0;
    final total = endDate!.difference(startDate!).inMinutes;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(startDate!).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  factory SponsorshipApplication.fromJson(Map<String, dynamic> j) {
    SponsorshipPlan? plan;
    if (j['plan'] != null) {
      plan = SponsorshipPlan.fromJson(j['plan'] as Map<String, dynamic>);
    }

    return SponsorshipApplication(
      id: (j['id'] as num).toInt(),
      vendorId: (j['vendor_id'] as num?)?.toInt() ?? 0,
      planId: (j['plan_id'] as num?)?.toInt() ?? 0,
      status: j['status'] as String? ?? 'pending',
      targetCategories: (j['target_categories'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      targetLocations: (j['target_locations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      targetKeywords: (j['target_keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      priority: (j['priority'] as num?)?.toInt() ?? 1,
      startDate: j['start_date'] != null
          ? DateTime.tryParse(j['start_date'].toString())
          : null,
      endDate: j['end_date'] != null
          ? DateTime.tryParse(j['end_date'].toString())
          : null,
      clickCount: (j['click_count'] as num?)?.toInt() ?? 0,
      viewCount: (j['view_count'] as num?)?.toInt() ?? 0,
      adminNotes: j['admin_notes'] as String?,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      plan: plan,
    );
  }
}

class SponsorApplyRequest {
  final int planId;
  final List<int> targetCategories;
  final List<String> targetLocations;
  final List<String> targetKeywords;

  const SponsorApplyRequest({
    required this.planId,
    required this.targetCategories,
    required this.targetLocations,
    required this.targetKeywords,
  });

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'target_categories': targetCategories,
        'target_locations': targetLocations,
        'target_keywords': targetKeywords,
      };
}
