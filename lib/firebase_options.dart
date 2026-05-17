// Fichier généré manuellement pour le MVP — exécute `flutterfire configure`
// avec ton vrai projet Firebase pour remplacer ces valeurs.
import "package:firebase_core/firebase_core.dart" show FirebaseOptions;
import "package:flutter/foundation.dart"
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Options Firebase par plateforme (MVP / placeholder).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        "OZELSERVICES : Firebase web non configuré pour ce MVP.",
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          "OZELSERVICES : plateforme non supportée pour Firebase.",
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyPlaceholderKeyNotValid0000000000",
    appId: "1:123456789000:android:abcdef00000000",
    messagingSenderId: "123456789000",
    projectId: "ozelservices-benin-placeholder",
    storageBucket: "ozelservices-benin-placeholder.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyPlaceholderIos000000000000000",
    appId: "1:123456789000:ios:abcdef00000001",
    messagingSenderId: "123456789000",
    projectId: "ozelservices-benin-placeholder",
    storageBucket: "ozelservices-benin-placeholder.appspot.com",
    iosBundleId: "com.example.ozelservices",
  );
}
