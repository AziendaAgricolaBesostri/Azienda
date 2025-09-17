// Fill these with your Firebase Web app config (Console Firebase > Impostazioni progetto > App Web)
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'PASTE_API_KEY',
        appId: 'PASTE_APP_ID',
        messagingSenderId: 'PASTE_SENDER_ID',
        projectId: 'PASTE_PROJECT_ID',
        authDomain: 'PASTE_PROJECT_ID.firebaseapp.com',
        storageBucket: 'PASTE_PROJECT_ID.appspot.com',
        measurementId: 'PASTE_MEASUREMENT_ID',
      );
    }
    return const FirebaseOptions(
      apiKey: 'PASTE_API_KEY',
      appId: 'PASTE_APP_ID',
      messagingSenderId: 'PASTE_SENDER_ID',
      projectId: 'PASTE_PROJECT_ID',
    );
  }
}
