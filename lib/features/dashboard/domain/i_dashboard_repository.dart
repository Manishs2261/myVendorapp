import 'dashboard_models.dart';

abstract class IDashboardRepository {
  Future<DashboardOverview> getOverview();
}
