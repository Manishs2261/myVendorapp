import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/dashboard_remote_source.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_models.dart';
import '../../domain/i_dashboard_repository.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRemoteSource dashboardRemoteSource(Ref ref) =>
    DashboardRemoteSource(ref.read(dioProvider));

@riverpod
IDashboardRepository dashboardRepository(Ref ref) =>
    DashboardRepository(ref.read(dashboardRemoteSourceProvider));

@riverpod
Future<DashboardOverview> dashboardOverview(Ref ref) =>
    ref.read(dashboardRepositoryProvider).getOverview();
