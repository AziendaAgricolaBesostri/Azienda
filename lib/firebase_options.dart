// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Usiamo sempre la config Web
    return const FirebaseOptions(
      apiKey: 'INSERISCI_API_KEY', // es. AIzaSyB...
      appId: 'INSERISCI_APP_ID', // es. 1:1234567890:web:abcd1234efgh5678
      messagingSenderId: 'INSERISCI_SENDER_ID', // es. 1234567890
      projectId: 'INSERISCI_PROJECT_ID', // es. besostri-farm
      authDomain: 'INSERISCI_AUTH_DOMAIN', // es. besostri-farm.firebaseapp.com
      storageBucket: 'INSERISCI_STORAGE_BUCKET', // es. besostri-farm.appspot.com
      measurementId: 'INSERISCI_MEASUREMENT_ID', // es. G-XXXXXXX (se non c'è, lascia '' )
    );
  }
}
