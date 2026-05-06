import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WhisperPiApp());
    expect(find.text('VOX_OS_INTELLIGENCE'), findsOneWidget);
  });
}
