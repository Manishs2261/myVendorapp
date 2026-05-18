import 'shop_models.dart';

abstract class IShopRepository {
  Future<Shop> getShop();
  Future<Shop> updateShop(Map<String, dynamic> data);
}
