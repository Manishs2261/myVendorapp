# My Shop — Vendor App

## Flavors

Three flavors are configured: **dev**, **stage**, and **prod**.

| Flavor | App Name      | App ID                        |
|--------|---------------|-------------------------------|
| dev    | My Shop Dev   | com.example.myvendorapp.dev   |
| stage  | My Shop Stage | com.example.myvendorapp.stage |
| prod   | My Shop       | com.example.myvendorapp       |

---

## Run (debug on device)

```bash
flutter run --flavor dev   -t lib/main_dev.dart
flutter run --flavor stage -t lib/main_stage.dart
flutter run --flavor prod  -t lib/main.dart
```

---

## Build APK — Debug

```bash
flutter build apk --debug --flavor dev   -t lib/main_dev.dart
flutter build apk --debug --flavor stage -t lib/main_stage.dart
flutter build apk --debug --flavor prod  -t lib/main.dart
```

## Build APK — Release

```bash
flutter build apk --release --flavor dev   -t lib/main_dev.dart
flutter build apk --release --flavor stage -t lib/main_stage.dart
flutter build apk --release --flavor prod  -t lib/main.dart
```

## Build App Bundle (Play Store)

```bash
flutter build appbundle --release --flavor prod -t lib/main.dart
```

---

## Build iOS (macOS only)

```bash
flutter run --flavor dev   -t lib/main_dev.dart
flutter run --flavor stage -t lib/main_stage.dart
flutter run --flavor prod  -t lib/main.dart

flutter build ios --release --flavor prod -t lib/main.dart
```

### iOS Scheme Setup (one-time, requires Xcode on macOS)

The xcconfig files are already created at `ios/Flutter/`:
- `Debug-Dev.xcconfig` / `Release-Dev.xcconfig`
- `Debug-Stage.xcconfig` / `Release-Stage.xcconfig`

To wire them up:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **Product → Scheme → Manage Schemes**
3. Duplicate **Runner** twice → rename to **Runner-Dev** and **Runner-Stage**
4. Edit each scheme → set **Build Configuration** to the matching xcconfig

---

## Changing API URLs per flavor

Edit `lib/core/config/app_config.dart`:

```dart
static String get apiBaseUrl => switch (_flavor) {
  AppFlavor.dev   => 'http://10.0.2.2:8000',
  AppFlavor.stage => 'https://staging-api.whereismyshops.com',
  AppFlavor.prod  => 'https://api.whereismyshops.com',
};
```

---

## Firebase setup for dev / stage

Per-flavor `google-services.json` files are at:
- `android/app/src/dev/google-services.json`
- `android/app/src/stage/google-services.json`
- `android/app/src/prod/google-services.json`

For FCM to work on dev/stage, register the package names in Firebase Console → Project **my-shop-31d1a** → Project Settings:
- Add Android app: `com.example.myvendorapp.dev`
- Add Android app: `com.example.myvendorapp.stage`

Then download the updated `google-services.json` and replace the files above.
