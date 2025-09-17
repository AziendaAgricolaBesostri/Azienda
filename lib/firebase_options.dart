// Fill these with your Firebase Web app config (Console Firebase > Impostazioni progetto > App Web)
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const firebaseConfig = {
        apiKey: "AIzaSyBeaK3IVK2u9Zj9_UAxrZbTGaLy-IMbxAE",
        authDomain: "besostri-farm.firebaseapp.com",
        projectId: "besostri-farm",
        storageBucket: "besostri-farm.firebasestorage.app",
        messagingSenderId: "305249453373",
        appId: "1:305249453373:web:d2453c53daf8c61dadb154",
        measurementId: "G-4436TL3S98"
      };
    }
    return const FirebaseOptions(
      apiKey: 'PASTE_API_KEY',
      appId: 'PASTE_APP_ID',
      messagingSenderId: 'PASTE_SENDER_ID',
      projectId: 'PASTE_PROJECT_ID',
    );
  }
}
