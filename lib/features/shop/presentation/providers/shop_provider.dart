import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/shop_remote_source.dart';
import '../../data/shop_repository.dart';
import '../../domain/i_shop_repository.dart';
import '../../domain/shop_models.dart';

part 'shop_provider.g.dart';

@riverpod
ShopRemoteSource shopRemoteSource(Ref ref) =>
    ShopRemoteSource(ref.read(dioProvider));

@riverpod
IShopRepository shopRepository(Ref ref) =>
    ShopRepository(ref.read(shopRemoteSourceProvider));

@riverpod
class ShopNotifier extends _$ShopNotifier {
  @override
  Future<Shop> build() =>
      ref.read(shopRepositoryProvider).getShop();

  Future<void> save(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(shopRepositoryProvider).updateShop(data),
    );
  }
}
