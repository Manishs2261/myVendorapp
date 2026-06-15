// IMPORTANT: This file contains placeholder values.
// Run `flutterfire configure --project=my-shop-31d1a` to generate real values.
// Or copy the real values from the Firebase console for project my-shop-31d1a
// (the same Firebase project used by myusesrapp).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with real values from Firebase console (project: my-shop-31d1a)

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOTmy_q9Zw2KlKeEk69Vq9dVSAmQ5k6_c',
    appId: '1:821841558401:android:38c6e0e08ac31f48110680',
    messagingSenderId: '821841558401',
    projectId: 'my-shop-31d1a',
    storageBucket: 'my-shop-31d1a.firebasestorage.app',
  );

  // Run: flutterfire configure --project=my-shop-31d1a

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2ISPORoQBGtYCg0O0q92AtvjesbMXL_Q',
    appId: '1:821841558401:ios:3d960f0a9ce33bec110680',
    messagingSenderId: '821841558401',
    projectId: 'my-shop-31d1a',
    storageBucket: 'my-shop-31d1a.firebasestorage.app',
    androidClientId: '821841558401-pes77usoeb1geaj91bgr0v5rjq1uings.apps.googleusercontent.com',
    iosClientId: '821841558401-dk1p42dh829qki0u9pnnoh1e1d3hbd9j.apps.googleusercontent.com',
    iosBundleId: 'com.whereismyshops.vendorapp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: '821841558401',
    projectId: 'my-shop-31d1a',
    storageBucket: 'my-shop-31d1a.appspot.com',
    authDomain: 'my-shop-31d1a.firebaseapp.com',
  );
}