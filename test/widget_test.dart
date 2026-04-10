import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guide shows skip button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const DrawingBoardApp(initialRoute: '/guide'),
    );
    await tester.pump();
    expect(find.text(Lang.guideSkip), findsOneWidget);
  });
}
