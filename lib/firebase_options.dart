// GENERATED-LIKE FILE (manually created). Replace placeholders after creating all platform apps in Firebase Console
// For production, run: flutterfire configure
// This manual file is only to unblock initialization (white screen fix).

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios; // placeholder – update after adding iOS app
      case TargetPlatform.macOS:
        return macos; // placeholder
      case TargetPlatform.windows:
        return windows; // placeholder
      case TargetPlatform.linux:
        return linux; // placeholder
      default:
        throw UnsupportedError('Unsupported platform for Firebase initialization');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBiM4yFNcbvLe1CbM_Cv3kn2M63oOHIVwg',
    appId: '1:418728202157:web:3af200ffacaa39e5b89b24',
    messagingSenderId: '418728202157',
    projectId: 'cholo-c9f90',
    authDomain: 'cholo-c9f90.firebaseapp.com',
    storageBucket: 'cholo-c9f90.firebasestorage.app',
    measurementId: 'G-WF9X47PVWR',
  );

  // Obtain real values for web from Firebase Console > Project settings > Your apps > Web app config.

  // Helper to detect placeholder config still present for web
  static bool get webConfigIsPlaceholder => web.appId.contains('REPLACE_');

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChOjj-SXIZMK6fVVAFJfPjcfUoTniJUjI',
    appId: '1:418728202157:android:5398e46a23d74ee6b89b24',
    messagingSenderId: '418728202157',
    projectId: 'cholo-c9f90',
    storageBucket: 'cholo-c9f90.firebasestorage.app',
  );

  // The following are placeholders so app does not crash on desktop/iOS if accidentally run.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_IOS_API_KEY',
    appId: 'REPLACE_IOS_APP_ID',
    messagingSenderId: '418728202157',
    projectId: 'cholo-c9f90',
    storageBucket: 'cholo-c9f90.firebasestorage.app',
    iosBundleId: 'com.cholo.cholo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_MACOS_API_KEY',
    appId: 'REPLACE_MACOS_APP_ID',
    messagingSenderId: '418728202157',
    projectId: 'cholo-c9f90',
    storageBucket: 'cholo-c9f90.firebasestorage.app',
    iosBundleId: 'com.cholo.cholo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WINDOWS_API_KEY',
    appId: 'REPLACE_WINDOWS_APP_ID',
    messagingSenderId: '418728202157',
    projectId: 'cholo-c9f90',
    storageBucket: 'cholo-c9f90.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_LINUX_API_KEY',
    appId: 'REPLACE_LINUX_APP_ID',
    messagingSenderId: '418728202157',
    projectId: 'cholo-c9f90',
    storageBucket: 'cholo-c9f90.firebasestorage.app',
  );
}