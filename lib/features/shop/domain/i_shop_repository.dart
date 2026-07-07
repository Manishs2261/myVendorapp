import 'package:image_picker/image_picker.dart';
import 'shop_models.dart';

abstract class IShopRepository {
  Future<Shop> getShop();
  Future<Shop> updateShop(Map<String, dynamic> data);
  Future<String> uploadLogo(XFile file);
  Future<String> uploadBanner(XFile file);
  Future<List<String>> uploadGallery(List<XFile> files);
  Future<void> removeGalleryImage(String url);
  Future<String> uploadIdDocument(XFile file);
  Future<Shop> updateShopStatus(String status);
  Future<void> closeShop(String? reason);
}
