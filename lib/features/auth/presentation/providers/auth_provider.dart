import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/auth_remote_source.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_models.dart';
import '../../domain/i_auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRemoteSource authRemoteSource(Ref ref) =>
    AuthRemoteSource(ref.read(dioProvider));

@riverpod
IAuthRepository authRepository(Ref ref) => AuthRepository(
      ref.read(authRemoteSourceProvider),
      ref.read(secureStorageProvider),
    );

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  Future<void> _saveFcmTokenSilently() async {
    try {
      final token = await FcmService.requestPermissionAndGetToken();
      if (token != null) {
        await ref.read(authRemoteSourceProvider).saveFcmToken(token);
      }
    } catch (_) {}
  }

  @override
  Future<VendorUser?> build() async {
    final token = await ref.read(authRepositoryProvider).getStoredToken();
    if (token == null) return null;
    try {
      final user = await ref.read(authRepositoryProvider).getMe();
      _saveFcmTokenSilently();
      return user;
    } catch (e) {
      if (e is UnauthorizedException) {
        await ref.read(authRepositoryProvider).logout();
      }
      // Network or transient errors: keep tokens intact so the next
      // successful launch auto-logs the user back in without re-entering credentials.
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(email: email, password: password));
      final user = await ref.read(authRepositoryProvider).getMe();
      _saveFcmTokenSilently();
      return user;
    });
  }

  Future<void> completeRegistration(String email, String otp) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).completeRegistration(email, otp);
      final user = await ref.read(authRepositoryProvider).getMe();
      _saveFcmTokenSilently();
      return user;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
