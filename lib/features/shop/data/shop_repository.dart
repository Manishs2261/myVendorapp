import 'package:image_picker/image_picker.dart';

import '../../../core/utils/json_parser.dart';
import '../domain/i_shop_repository.dart';
import '../domain/shop_models.dart';
import 'shop_remote_source.dart';

class ShopRepository implements IShopRepository {
  final ShopRemoteSource _remote;
  ShopRepository(this._remote);

  @override
  Future<Shop> getShop() async {
    final data = await _remote.getShop();
    return parseJson('Shop', data, Shop.fromJson);
  }

  @override
  Future<Shop> updateShop(Map<String, dynamic> data) async {
    final updated = await _remote.updateShop(data);
    return parseJson('Shop', updated, Shop.fromJson);
  }

  Future<Shop> requestVerification() async {
    final data = await _remote.requestVerification();
    return parseJson('Shop', data, Shop.fromJson);
  }

  @override
  Future<String> uploadLogo(XFile file) => _remote.uploadLogo(file);

  @override
  Future<String> uploadBanner(XFile file) => _remote.uploadBanner(file);

  @override
  Future<List<String>> uploadGallery(List<XFile> files) =>
      _remote.uploadGallery(files);

  @override
  Future<void> removeGalleryImage(String url) =>
      _remote.removeGalleryImage(url);

  @override
  Future<String> uploadIdDocument(XFile file) =>
      _remote.uploadIdDocument(file);
}
