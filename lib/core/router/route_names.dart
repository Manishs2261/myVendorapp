abstract final class RouteNames {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const productDetail = '/products/:id';
  static const addProduct = '/add-product';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const shop = '/shop';
  static const profile = '/profile';

  static const editProduct = '/products/:id/edit';

  static String productDetailPath(String id) => '/products/$id';
  static String editProductPath(String id) => '/products/$id/edit';
  static String orderDetailPath(String id) => '/orders/$id';
}
