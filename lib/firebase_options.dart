// This file is a placeholder. It will be overwritten by the FlutterFire CLI.
// Run:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// and it will generate the real DefaultFirebaseOptions with platform configs.

// ignore_for_file: constant_identifier_names

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError('Run flutterfire configure to generate firebase_options.dart');
  }
}