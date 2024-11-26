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
    apiKey: 'AIzaSyCipKyqJ3WlzdULvEeetulqUCoevZdYBQ8',
    appId: '1:293014776718:web:907516bb0d3de691a2ae49',
    messagingSenderId: '293014776718',
    projectId: 'abastecimentoavanco-95004',
    authDomain: 'abastecimentoavanco-95004.firebaseapp.com',
    storageBucket: 'abastecimentoavanco-95004.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkDmDQg_gdVJBZb_jnZyrrXzI_fDT8we0',
    appId: '1:293014776718:android:73cdd2f12f828f52a2ae49',
    messagingSenderId: '293014776718',
    projectId: 'abastecimentoavanco-95004',
    storageBucket: 'abastecimentoavanco-95004.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBi55T9Uzi6gFrFOIFzIeU7pw_aTsIzQU4',
    appId: '1:293014776718:ios:aa54967462e3aef6a2ae49',
    messagingSenderId: '293014776718',
    projectId: 'abastecimentoavanco-95004',
    storageBucket: 'abastecimentoavanco-95004.firebasestorage.app',
    iosBundleId: 'com.Abastecimento',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBi55T9Uzi6gFrFOIFzIeU7pw_aTsIzQU4',
    appId: '1:293014776718:ios:aa54967462e3aef6a2ae49',
    messagingSenderId: '293014776718',
    projectId: 'abastecimentoavanco-95004',
    storageBucket: 'abastecimentoavanco-95004.firebasestorage.app',
    iosBundleId: 'com.Abastecimento',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCipKyqJ3WlzdULvEeetulqUCoevZdYBQ8',
    appId: '1:293014776718:web:9e6a626605b249eca2ae49',
    messagingSenderId: '293014776718',
    projectId: 'abastecimentoavanco-95004',
    authDomain: 'abastecimentoavanco-95004.firebaseapp.com',
    storageBucket: 'abastecimentoavanco-95004.firebasestorage.app',
  );
}
