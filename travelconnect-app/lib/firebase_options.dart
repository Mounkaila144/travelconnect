import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'AIzaSyAtH5GJNlb61v-qpU9XTLlJKwNn08RNwPc',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:409369756105:web:0000000000000000',
    ),
    messagingSenderId: '409369756105',
    projectId: 'travelconect',
    authDomain: 'travelconect.firebaseapp.com',
    storageBucket: 'travelconect.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAtH5GJNlb61v-qpU9XTLlJKwNn08RNwPc',
    appId: '1:409369756105:android:1dd3b900380990ed6fe818',
    messagingSenderId: '409369756105',
    projectId: 'travelconect',
    storageBucket: 'travelconect.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDry55z7CIhw9G3TVvouyqsEsnEBjtyRBI',
    appId: '1:409369756105:ios:2d4b5bd8df5e77ef6fe818',
    messagingSenderId: '409369756105',
    projectId: 'travelconect',
    storageBucket: 'travelconect.firebasestorage.app',
    iosBundleId: 'com.travelconnect.app',
  );
}
