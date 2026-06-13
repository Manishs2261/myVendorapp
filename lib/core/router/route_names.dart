abstract final class RouteNames {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyCode = '/verify-code';
  static const newPassword = '/new-password';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const productDetail = '/products/:id';
  static const addProduct = '/add-product';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const shop = '/shop';
  static const profile = '/profile';

  static const editProduct = '/products/:id/edit';

  static const analytics        = '/analytics';
  static const marketplace      = '/marketplace';
  static const promotions       = '/promotions';
  static const sponsorship      = '/sponsorship';
  static const shopReviews      = '/shop-reviews';
  static const productReviews   = '/product-reviews';
  static const helpFeedback     = '/help-feedback';
  static const storefrontEditor = '/storefront-editor';
  static const payments         = '/payments';
  static const notifications    = '/notifications';
  static const settings         = '/settings';

  static const drafts     = '/products/drafts';
  static const aiPreview  = '/ai-preview';
  static const cropEditor = '/crop-editor';

  static String productDetailPath(String id) => '/products/$id';
  static String editProductPath(String id) => '/products/$id/edit';
  static String orderDetailPath(String id) => '/orders/$id';
}
