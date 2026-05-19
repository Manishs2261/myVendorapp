abstract final class RouteNames {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const productDetail = '/products/:id';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const shop = '/shop';
  static const profile = '/profile';

  static String productDetailPath(String id) => '/products/$id';
  static String orderDetailPath(String id) => '/orders/$id';
}
