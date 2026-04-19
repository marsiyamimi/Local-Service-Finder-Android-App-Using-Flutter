import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported.');
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArCb5U20XTfm0IeAZxnjLQohfqWZ5Ya9I',
    appId: '1:582143599508:android:51e728c9e790fc86456581',
    messagingSenderId: '582143599508',
    projectId: 'localservicefinder-d4fc1',
    storageBucket: 'localservicefinder-d4fc1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGyO3ePJfQyXXb5DJIz7yHOXHIiwFXJFQ',
    appId: '1:582143599508:ios:42160d4f4488550f456581',
    messagingSenderId: '582143599508',
    projectId: 'localservicefinder-d4fc1',
    storageBucket: 'localservicefinder-d4fc1.firebasestorage.app',
    iosBundleId: 'com.mimi.localservicefinder',
  );
}
