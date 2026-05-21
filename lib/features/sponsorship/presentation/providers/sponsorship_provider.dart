import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/sponsorship_remote_source.dart';
import '../../data/sponsorship_repository.dart';
import '../../domain/sponsorship_models.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SponsorshipState {
  final List<SponsorshipPlan> plans;
  final List<SponsorshipApplication> applications;
  final bool loading;
  final String? error;
  final bool submitting;
  final bool cancelling;

  const SponsorshipState({
    this.plans = const [],
    this.applications = const [],
    this.loading = false,
    this.error,
    this.submitting = false,
    this.cancelling = false,
  });

  SponsorshipState copyWith({
    List<SponsorshipPlan>? plans,
    List<SponsorshipApplication>? applications,
    bool? loading,
    String? error,
    bool? submitting,
    bool? cancelling,
    bool clearError = false,
  }) =>
      SponsorshipState(
        plans: plans ?? this.plans,
        applications: applications ?? this.applications,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        submitting: submitting ?? this.submitting,
        cancelling: cancelling ?? this.cancelling,
      );

  SponsorshipApplication? get activeApplication =>
      applications.cast<SponsorshipApplication?>().firstWhere(
            (a) => a!.isActive,
            orElse: () => null,
          );

  bool hasPendingForPlan(int planId) => applications.any(
        (a) => a.planId == planId && (a.status == 'pending' || a.isActive),
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SponsorshipNotifier extends StateNotifier<SponsorshipState> {
  final SponsorshipRepository _repo;

  SponsorshipNotifier(this._repo) : super(const SponsorshipState());

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getPlans(),
        _repo.getApplications(),
      ]);
      state = state.copyWith(
        loading: false,
        plans: results[0] as List<SponsorshipPlan>,
        applications: results[1] as List<SponsorshipApplication>,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> apply(SponsorApplyRequest request) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final application = await _repo.apply(request);
      state = state.copyWith(
        submitting: false,
        applications: [application, ...state.applications],
      );
      return true;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancel(int sponsorshipId) async {
    state = state.copyWith(cancelling: true, clearError: true);
    try {
      await _repo.cancel(sponsorshipId);
      state = state.copyWith(
        cancelling: false,
        applications: state.applications
            .where((a) => a.id != sponsorshipId)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(cancelling: false, error: e.toString());
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final sponsorshipRemoteSourceProvider = Provider<SponsorshipRemoteSource>(
  (ref) => SponsorshipRemoteSource(ref.read(dioProvider)),
);

final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>(
  (ref) => SponsorshipRepository(ref.read(sponsorshipRemoteSourceProvider)),
);

final sponsorshipProvider =
    StateNotifierProvider<SponsorshipNotifier, SponsorshipState>(
  (ref) => SponsorshipNotifier(ref.read(sponsorshipRepositoryProvider)),
);
