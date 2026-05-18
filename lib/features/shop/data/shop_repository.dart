import '../domain/i_shop_repository.dart';
import '../domain/shop_models.dart';
import 'shop_remote_source.dart';

class ShopRepository implements IShopRepository {
  final ShopRemoteSource _remote;
  ShopRepository(this._remote);

  @override
  Future<Shop> getShop() async {
    final data = await _remote.getShop();
    return Shop.fromJson(data);
  }

  @override
  Future<Shop> updateShop(Map<String, dynamic> data) async {
    final updated = await _remote.updateShop(data);
    return Shop.fromJson(updated);
  }
}
