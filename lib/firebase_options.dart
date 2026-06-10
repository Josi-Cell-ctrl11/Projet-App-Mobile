// Fichier généré par flutterfire configure — projet Firebase : aquazen-b1a7d
// Ne pas committer ce fichier publiquement (clés sensibles).
import "package:firebase_core/firebase_core.dart" show FirebaseOptions;
import "package:flutter/foundation.dart"
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
      default:
        throw UnsupportedError(
          "DefaultFirebaseOptions ne supporte pas cette plateforme.",
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1gyoTRui5vyFPifpis8nlJ0IWnBcGjMs',
    appId: '1:290294089161:android:906ae63e18e75a578cd418',
    messagingSenderId: '290294089161',
    projectId: 'aquazen-b1a7d',
    storageBucket: 'aquazen-b1a7d.firebasestorage.app',
  );
  // iOS/macOS/web — exécuter `flutterfire configure` pour remplacer les appId placeholder.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyA1gyoTRui5vyFPifpis8nlJ0IWnBcGjMs",
    appId: "1:290294089161:ios:000000000000000",
    messagingSenderId: "290294089161",
    projectId: "aquazen-b1a7d",
    storageBucket: "aquazen-b1a7d.firebasestorage.app",
    iosBundleId: "bj.ozelservices.client",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyA1gyoTRui5vyFPifpis8nlJ0IWnBcGjMs",
    appId: "1:290294089161:ios:000000000000000",
    messagingSenderId: "290294089161",
    projectId: "aquazen-b1a7d",
    storageBucket: "aquazen-b1a7d.firebasestorage.app",
    iosBundleId: "bj.ozelservices.client",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyA1gyoTRui5vyFPifpis8nlJ0IWnBcGjMs",
    appId: "1:290294089161:web:000000000000000",
    messagingSenderId: "290294089161",
    projectId: "aquazen-b1a7d",
    storageBucket: "aquazen-b1a7d.firebasestorage.app",
  );
}
