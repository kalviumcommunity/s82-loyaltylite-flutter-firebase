// TODO: Replace with real Firebase options via flutterfire CLI.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace the values below with your platform-specific Firebase configs.
    return const FirebaseOptions(
      apiKey: 'REPLACE_ME',
      appId: 'REPLACE_ME',
      messagingSenderId: 'REPLACE_ME',
      projectId: 'REPLACE_ME',
    );
  }
}
