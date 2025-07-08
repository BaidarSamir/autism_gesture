import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY_WEB']!,
        appId: dotenv.env['FIREBASE_APP_ID_WEB']!,
        messagingSenderId: dotenv.env['FIREBASE_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN_WEB']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID_WEB'],
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_ANDROID']!,
          appId: dotenv.env['FIREBASE_APP_ID_ANDROID']!,
          messagingSenderId: dotenv.env['FIREBASE_SENDER_ID']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
        );

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_IOS']!,
          appId: dotenv.env['FIREBASE_APP_ID_IOS']!,
          messagingSenderId: dotenv.env['FIREBASE_SENDER_ID']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
          iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID']!,
        );

      case TargetPlatform.windows:
        // Use web config as fallback
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_WEB']!,
          appId: dotenv.env['FIREBASE_APP_ID_WEB']!,
          messagingSenderId: dotenv.env['FIREBASE_SENDER_ID']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
        );

      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
