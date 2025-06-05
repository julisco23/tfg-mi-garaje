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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAql56LeP2IxDICHjPk_H-_RlHHuIZ2tgs',
    appId: '1:561232468341:web:2b57fb0f78ac1866369b3c',
    messagingSenderId: '561232468341',
    projectId: 'tfg-migaraje',
    authDomain: 'tfg-migaraje.firebaseapp.com',
    storageBucket: 'tfg-migaraje.firebasestorage.app',
    measurementId: 'G-H6N2VXJ0XN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgkFMM4ev9Pb6zu-zlI3zXl5j5fsWyy4A',
    appId: '1:561232468341:android:94f33a5e936d821d369b3c',
    messagingSenderId: '561232468341',
    projectId: 'tfg-migaraje',
    storageBucket: 'tfg-migaraje.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoRXxS0QKQPXbNkGCi9kiWxQUHfrm6Y7Q',
    appId: '1:561232468341:ios:9037f6bece42c7fd369b3c',
    messagingSenderId: '561232468341',
    projectId: 'tfg-migaraje',
    storageBucket: 'tfg-migaraje.firebasestorage.app',
    iosBundleId: 'com.example.prueba',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAql56LeP2IxDICHjPk_H-_RlHHuIZ2tgs',
    appId: '1:561232468341:web:4f592cc2e6f23bcc369b3c',
    messagingSenderId: '561232468341',
    projectId: 'tfg-migaraje',
    authDomain: 'tfg-migaraje.firebaseapp.com',
    storageBucket: 'tfg-migaraje.firebasestorage.app',
    measurementId: 'G-KS1BYQYG9V',
  );
}
