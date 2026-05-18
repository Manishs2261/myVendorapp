import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/profile_remote_source.dart';
import '../../data/profile_repository.dart';
import '../../domain/i_profile_repository.dart';
import '../../domain/profile_models.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRemoteSource profileRemoteSource(Ref ref) =>
    ProfileRemoteSource(ref.read(dioProvider));

@riverpod
IProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.read(profileRemoteSourceProvider));

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<VendorProfile> build() =>
      ref.read(profileRepositoryProvider).getProfile();

  Future<void> save(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).updateProfile(data),
    );
  }
}
