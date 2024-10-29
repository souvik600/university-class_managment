// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD33RyITeVObgV7IllKcKjSGgf8LGYDNgw',
    appId: '1:347165694100:web:7b00c451345dbd22ee7c81',
    messagingSenderId: '347165694100',
    projectId: 'nubtk-cse',
    authDomain: 'nubtk-cse.firebaseapp.com',
    storageBucket: 'nubtk-cse.appspot.com',
    measurementId: 'G-SZ3HPM5ZL6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvnyYL7UN7zLkFRKYmAOlO7fx_yQEVcUI',
    appId: '1:347165694100:android:dff9218bfa329b09ee7c81',
    messagingSenderId: '347165694100',
    projectId: 'nubtk-cse',
    storageBucket: 'nubtk-cse.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLPVkbW0542xWCgOqtCu0KNhFqKrfHpzM',
    appId: '1:347165694100:ios:43011cdc0f652c61ee7c81',
    messagingSenderId: '347165694100',
    projectId: 'nubtk-cse',
    storageBucket: 'nubtk-cse.appspot.com',
    iosBundleId: 'com.example.nubtkCse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDLPVkbW0542xWCgOqtCu0KNhFqKrfHpzM',
    appId: '1:347165694100:ios:43011cdc0f652c61ee7c81',
    messagingSenderId: '347165694100',
    projectId: 'nubtk-cse',
    storageBucket: 'nubtk-cse.appspot.com',
    iosBundleId: 'com.example.nubtkCse',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD33RyITeVObgV7IllKcKjSGgf8LGYDNgw',
    appId: '1:347165694100:web:5fc950499292fc13ee7c81',
    messagingSenderId: '347165694100',
    projectId: 'nubtk-cse',
    authDomain: 'nubtk-cse.firebaseapp.com',
    storageBucket: 'nubtk-cse.appspot.com',
    measurementId: 'G-LGN98MY3K2',
  );
}