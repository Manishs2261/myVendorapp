import '../../../core/utils/json_parser.dart';
import '../domain/sponsorship_models.dart';
import 'sponsorship_remote_source.dart';

class SponsorshipRepository {
  final SponsorshipRemoteSource _remote;
  SponsorshipRepository(this._remote);

  Future<List<SponsorshipPlan>> getPlans() async {
    final data = await _remote.getPlans();
    return parseJsonList('SponsorshipPlan', data, SponsorshipPlan.fromJson);
  }

  Future<List<SponsorshipApplication>> getApplications() async {
    final data = await _remote.getStatus();
    return parseJsonList(
        'SponsorshipApplication', data, SponsorshipApplication.fromJson);
  }

  Future<SponsorshipApplication> apply(SponsorApplyRequest request) async {
    final data = await _remote.apply(request.toJson());
    return parseJson(
        'SponsorshipApplication', data, SponsorshipApplication.fromJson);
  }

  Future<void> cancel(int sponsorshipId) => _remote.cancel(sponsorshipId);
}
