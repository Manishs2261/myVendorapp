import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
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
  @override
  Future<VendorUser?> build() async {
    final token = await ref.read(authRepositoryProvider).getStoredToken();
    if (token == null) return null;
    try {
      return await ref.read(authRepositoryProvider).getMe();
    } catch (_) {
      await ref.read(authRepositoryProvider).logout();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(email: email, password: password));
      return ref.read(authRepositoryProvider).getMe();
    });
  }

  Future<void> register({
    required String businessName,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).register(
            RegisterRequest(
              businessName: businessName,
              email: email,
              password: password,
              phone: phone,
            ),
          );
      return ref.read(authRepositoryProvider).getMe();
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
