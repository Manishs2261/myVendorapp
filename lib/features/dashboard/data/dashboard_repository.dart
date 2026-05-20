import '../../../core/utils/json_parser.dart';
import '../domain/dashboard_models.dart';
import '../domain/i_dashboard_repository.dart';
import 'dashboard_remote_source.dart';

class DashboardRepository implements IDashboardRepository {
  final DashboardRemoteSource _remote;
  DashboardRepository(this._remote);

  @override
  Future<DashboardOverview> getOverview() async {
    final data = await _remote.getOverview();
    return parseJson('DashboardOverview', data, DashboardOverview.fromJson);
  }
}
