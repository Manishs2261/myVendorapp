class CacheKeys {
  const CacheKeys._();

  static const dashboard = 'dashboard_overview';
  static String analytics(String period) => 'shop_analytics_$period';
  static const productsPage1 = 'products_list_p1';
  static const ordersPage1 = 'orders_list_p1';
  static const profile = 'vendor_profile';
  static const shopProfile = 'shop_profile';
  static const categories = 'categories';
  static const notificationsPage1 = 'notifications_p1';
  static const shopSettings = 'shop_settings';
}
