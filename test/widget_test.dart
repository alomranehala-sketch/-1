import 'package:flutter_test/flutter_test.dart';

import 'package:robot_intro_3d/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const RobotApp());
    await tester.pumpAndSettle();

    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
