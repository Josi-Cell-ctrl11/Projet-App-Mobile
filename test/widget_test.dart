import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:ozelservices/app.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets("OzelApp se construit", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OzelApp()));
    await tester.pump();
  });
}
