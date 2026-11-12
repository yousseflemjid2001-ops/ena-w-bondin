import 'package:flutter_test/flutter_test.dart';
import 'package:fidness_mobile_hub/main.dart';

void main() {
  testWidgets('FidnessOmniHubApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FidnessOmniHubApp());
    expect(find.byType(FidnessOmniHubApp), findsOneWidget);
  });
}
