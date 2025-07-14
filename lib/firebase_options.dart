// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDkamovR76dSwMp0q2_5T-8aoiHuO2p2K8",
      authDomain: "acqadvantage.firebaseapp.com",
      projectId: "acqadvantage",
      storageBucket: "acqadvantage.appspot.com",
      messagingSenderId: "701387918539",
      appId: "1:701387918539:web:b5d78e122a724da095df4e",
      measurementId: "G-P8D1EC5RL0",
    );
  }
}