import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the registered Neospend project.
///
/// The Android application is registered in google-services.json. The web
/// configuration uses the same Firebase project so the Flutter web target can
/// initialize Firebase instead of failing when FirebaseAuth is first used.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAXOjfw89gsNTw5fO-lz3EYnzQTzCl_ABY',
    appId: '1:29661089352:android:4c46032d5674d5896c927d',
    messagingSenderId: '29661089352',
    projectId: 'neospend-97721',
    authDomain: 'neospend-97721.firebaseapp.com',
    storageBucket: 'neospend-97721.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXOjfw89gsNTw5fO-lz3EYnzQTzCl_ABY',
    appId: '1:29661089352:android:4c46032d5674d5896c927d',
    messagingSenderId: '29661089352',
    projectId: 'neospend-97721',
    storageBucket: 'neospend-97721.firebasestorage.app',
  );
}
