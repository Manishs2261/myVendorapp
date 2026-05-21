import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../data/help_remote_source.dart';
import '../../data/help_repository.dart';
import '../../domain/help_models.dart';

part 'help_provider.g.dart';

@riverpod
HelpRemoteSource helpRemoteSource(Ref ref) =>
    HelpRemoteSource(ref.read(dioProvider));

@riverpod
HelpRepository helpRepository(Ref ref) =>
    HelpRepository(ref.read(helpRemoteSourceProvider));

@riverpod
Future<PaginatedResponse<FeedbackItem>> helpFeedbackList(
  Ref ref, {
  String? type,
  String? status,
  int page = 1,
}) =>
    ref.read(helpRepositoryProvider).getFeedbackList(
          type: type,
          status: status,
          page: page,
        );

@riverpod
class SubmitFeedbackNotifier extends _$SubmitFeedbackNotifier {
  @override
  AsyncValue<FeedbackItem?> build() => const AsyncData(null);

  Future<bool> submit(FeedbackCreate create) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(helpRepositoryProvider).submitFeedback(create),
    );
    state = result.whenData((item) => item);
    if (result.hasError) return false;
    ref.invalidate(helpFeedbackListProvider);
    return true;
  }

  void reset() => state = const AsyncData(null);
}
