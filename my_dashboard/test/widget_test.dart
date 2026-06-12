import 'package:flutter_test/flutter_test.dart';
import 'package:my_dashboard/main.dart';

void main() {
  testWidgets('app boots into the dashboard with demo data',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AppendApp());
    // Let the mock-data load (350ms simulated delay) finish.
    await tester.pumpAndSettle();

    expect(find.text('append.io'), findsOneWidget);
    expect(find.text('NET WORTH'), findsOneWidget);
  });
}
