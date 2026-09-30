// File generated for Agendify Flutter - Firebase project agendify-ae460.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCpMSuGmkUVPCndHs_YauCuxY8YHd-SnAA',
    appId: '1:62486214684:web:8937a0c4d422bd8c34c7d9',
    messagingSenderId: '62486214684',
    projectId: 'agendify-ae460',
    authDomain: 'agendify-ae460.firebaseapp.com',
    storageBucket: 'agendify-ae460.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDlk-qxj2tL04bVpEKzRGO6gnKk3BUgHA',
    appId: '1:62486214684:android:7bfd7ffa9d6f680534c7d9',
    messagingSenderId: '62486214684',
    projectId: 'agendify-ae460',
    storageBucket: 'agendify-ae460.firebasestorage.app',
  );

  static const FirebaseOptions ios = web;
  static const FirebaseOptions macos = web;
  static const FirebaseOptions windows = web;
}
