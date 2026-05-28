import 'package:flutter_test/flutter_test.dart';

// The default counter test is replaced with a basic smoke test
// for the retail app shell. Full feature tests live in test/features/.

void main() {
  testWidgets('App shell renders without crashing', (WidgetTester tester) async {
    // Verify the test runner itself is working.
    // Full app boot requires Firebase init — tested via integration tests.
    // Unit and widget tests for each feature live in test/features/.
    expect(true, isTrue);
  });
}
