import '../../../core/utils/json_parser.dart';
import '../../../shared/models/paginated_response.dart';
import '../domain/help_models.dart';
import 'help_remote_source.dart';

class HelpRepository {
  final HelpRemoteSource _remote;
  HelpRepository(this._remote);

  Future<PaginatedResponse<FeedbackItem>> getFeedbackList({
    String? type,
    String? status,
    int page = 1,
  }) async {
    final data = await _remote.getFeedbackList(
      type: type,
      status: status,
      page: page,
    );
    return parseJson(
      'PaginatedResponse<FeedbackItem>',
      data,
      (json) => PaginatedResponse.fromJson(json, FeedbackItem.fromJson),
    );
  }

  Future<FeedbackItem> submitFeedback(FeedbackCreate create) async {
    final data = await _remote.submitFeedback(create.toJson());
    return parseJson('FeedbackItem', data, FeedbackItem.fromJson);
  }
}
