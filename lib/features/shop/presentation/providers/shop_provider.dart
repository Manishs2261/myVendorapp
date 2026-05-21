import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/shop_remote_source.dart';
import '../../data/shop_repository.dart';
import '../../domain/i_shop_repository.dart';
import '../../domain/shop_models.dart';
import '../../domain/shop_review_models.dart';

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

  Future<void> uploadLogo(XFile file) async {
    final prev = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = await ref.read(shopRepositoryProvider).uploadLogo(file);
      final shop = prev.valueOrNull;
      if (shop == null) return ref.read(shopRepositoryProvider).getShop();
      return shop.copyWith(logoUrl: url);
    });
  }

  Future<void> uploadBanner(XFile file) async {
    final prev = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = await ref.read(shopRepositoryProvider).uploadBanner(file);
      final shop = prev.valueOrNull;
      if (shop == null) return ref.read(shopRepositoryProvider).getShop();
      return shop.copyWith(bannerUrl: url);
    });
  }

  Future<void> uploadGallery(List<XFile> files) async {
    final prev = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final urls = await ref.read(shopRepositoryProvider).uploadGallery(files);
      final shop = prev.valueOrNull;
      if (shop == null) return ref.read(shopRepositoryProvider).getShop();
      return shop.copyWith(gallery: [...shop.gallery, ...urls]);
    });
  }

  Future<void> removeGalleryImage(String url) async {
    final prev = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(shopRepositoryProvider).removeGalleryImage(url);
      final shop = prev.valueOrNull;
      if (shop == null) return ref.read(shopRepositoryProvider).getShop();
      return shop.copyWith(
        gallery: shop.gallery.where((u) => u != url).toList(),
      );
    });
  }

  Future<void> uploadIdDocument(XFile file) async {
    final prev = state;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url =
          await ref.read(shopRepositoryProvider).uploadIdDocument(file);
      final shop = prev.valueOrNull;
      if (shop == null) return ref.read(shopRepositoryProvider).getShop();
      return shop.copyWith(idDocumentUrl: url);
    });
  }
}

@riverpod
Future<ShopReviewStats> shopReviewStats(Ref ref) async {
  final data = await ref.read(shopRemoteSourceProvider).getReviewStats();
  return ShopReviewStats.fromJson(data);
}
