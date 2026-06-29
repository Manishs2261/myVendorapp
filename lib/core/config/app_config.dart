enum AppFlavor { dev, stage, prod }

class AppConfig {
  static AppFlavor _flavor = AppFlavor.prod;

  static AppFlavor get flavor => _flavor;

  static void initialize(AppFlavor flavor) => _flavor = flavor;

  static String get apiBaseUrl => switch (_flavor) {
       //    TODO change to url
        AppFlavor.dev => 'https://api.whereismyshops.com',
        AppFlavor.stage => 'https://api.whereismyshops.com',
        AppFlavor.prod => 'https://api.whereismyshops.com',
      };

  static String get appName => switch (_flavor) {
        AppFlavor.dev => 'My Shop Dev',
        AppFlavor.stage => 'My Shop Stage',
        AppFlavor.prod => 'My Shop Seller',
      };

  static bool get isProduction => _flavor == AppFlavor.prod;
}
