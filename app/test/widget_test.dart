import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/app.dart';

void main() {
  testWidgets('MomentsApp smoke test pumps and displays Moments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Moments'), findsOneWidget);
  });
}
