import "package:firebase_analytics/firebase_analytics.dart";

/// Instance Analytics globale — accessible depuis toute l'app.
final analytics = FirebaseAnalytics.instance;
final analyticsObserver = FirebaseAnalyticsObserver(analytics: analytics);
