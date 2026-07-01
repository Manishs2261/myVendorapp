class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String login = '/auth/login/vendor';
  static const String registerInitiate = '/auth/register/vendor/initiate';
  static const String registerComplete = '/auth/register/vendor/complete';
  static const String registerResend = '/auth/register/vendor/resend';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String fcmToken = '/auth/fcm-token';
  static const String changePassword = '/auth/change-password';
  static const String verifyEmailSend = '/auth/verify/email/send';
  static const String verifyEmailConfirm = '/auth/verify/email/confirm';
  static const String verifyPhoneSend = '/auth/verify/phone/send';
  static const String verifyPhoneConfirm = '/auth/verify/phone/confirm';

  // ---- Products ----
  static const String products = '/m/vendor/products';
  static String productById(int id) => '/m/vendor/products/$id';
  static String productPublish(int id) => '/m/vendor/products/$id/publish';
  static String productSponsorRequest(int productId) =>
      '/m/vendor/products/$productId/sponsor-request';
  static const String categories = '/public/categories';
  static const String aiRemoveBackground = '/m/vendor/ai/remove-background';

  // ---- Orders ----
  static const String orders = '/m/vendor/orders';
  static String orderById(int id) => '/m/vendor/orders/$id';
  static String orderStatus(int id) => '/m/vendor/orders/$id/status';

  // ---- Shop ----
  static const String shop = '/m/vendor/shop';
  static const String shopRequestVerification = '/m/vendor/shop/request-verification';
  static const String shopReviewsStats = '/m/vendor/shop-reviews/stats';
  static const String shopReviews = '/m/vendor/shop-reviews';
  static const String shopLogo = '/m/vendor/shop/logo';
  static const String shopBanner = '/m/vendor/shop/banner';
  static const String shopGallery = '/m/vendor/shop/gallery';
  static const String shopIdDocument = '/m/vendor/shop/id-document';
  static const String reviewsStats = '/m/vendor/reviews/stats';
  static const String reviews = '/m/vendor/reviews';

  // ---- Notifications ----
  static const String notifications = '/m/vendor/notifications';
  static String notificationRead(String id) => '/m/vendor/notifications/$id/read';
  static const String notificationsReadAll = '/m/vendor/notifications/read-all';
  static const String notificationsUnreadCount = '/m/vendor/notifications/unread-count';

  // ---- Dashboard / Analytics ----
  static const String dashboard = '/m/vendor/dashboard';
  static const String analyticsOverview = '/vendor/analytics/v2/overview';
  static const String analyticsProducts = '/vendor/analytics/v2/products';
  static const String analyticsSearchKeywords = '/vendor/analytics/v2/search-keywords';
  static const String analyticsActions = '/vendor/analytics/v2/actions';
  static const String analyticsDailyTraffic = '/vendor/analytics/v2/charts/daily-traffic';
  static const String analyticsInsights = '/vendor/analytics/v2/insights';

  // ---- Profile ----
  static const String profileMe = '/m/vendor/me';

  // ---- Help ----
  static const String helpFeedback = '/m/vendor/help/feedback';

  // ---- Sponsorship ----
  static const String sponsorshipPlans = '/sponsorships/vendor/plans';
  static const String sponsorshipStatus = '/sponsorships/vendor/status';
  static const String sponsorshipApply = '/sponsorships/vendor/apply';
  static String sponsorshipCancel(int sponsorshipId) =>
      '/sponsorships/vendor/$sponsorshipId/cancel';
}
