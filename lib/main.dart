import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "app.dart";

Future<void> main() async {
  await bootstrapApp();
  runApp(const ProviderScope(child: OzelApp()));
}
