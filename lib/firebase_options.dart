
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
    apiKey: 'AIzaSyAHRC3eVpG9izH1NOrQLjJwwi-agWI92hg',
    appId: '1:293626155083:web:47783fe30e34b03fc07dce',
    messagingSenderId: '293626155083',
    projectId: 'campus-incident-app-ridaa',
    authDomain: 'campus-incident-app-ridaa.firebaseapp.com',
    storageBucket: 'campus-incident-app-ridaa.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIklB9yZ2xLWJON-QlETkKmomGIX3Gp4M',
    appId: '1:293626155083:android:bb8dcb587eb6aaf6c07dce',
    messagingSenderId: '293626155083',
    projectId: 'campus-incident-app-ridaa',
    storageBucket: 'campus-incident-app-ridaa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgwF_KYHJDspPVaY8b_0_DshCCUxMH9Eg',
    appId: '1:293626155083:ios:8207fe0960023d91c07dce',
    messagingSenderId: '293626155083',
    projectId: 'campus-incident-app-ridaa',
    storageBucket: 'campus-incident-app-ridaa.firebasestorage.app',
    iosBundleId: 'com.yourname.campusIncidentApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgwF_KYHJDspPVaY8b_0_DshCCUxMH9Eg',
    appId: '1:293626155083:ios:8207fe0960023d91c07dce',
    messagingSenderId: '293626155083',
    projectId: 'campus-incident-app-ridaa',
    storageBucket: 'campus-incident-app-ridaa.firebasestorage.app',
    iosBundleId: 'com.yourname.campusIncidentApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAHRC3eVpG9izH1NOrQLjJwwi-agWI92hg',
    appId: '1:293626155083:web:c61c16df7464dfcac07dce',
    messagingSenderId: '293626155083',
    projectId: 'campus-incident-app-ridaa',
    authDomain: 'campus-incident-app-ridaa.firebaseapp.com',
    storageBucket: 'campus-incident-app-ridaa.firebasestorage.app',
  );
}
