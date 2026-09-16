import 'package:flutter_test/flutter_test.dart';

import 'package:agendify/app.dart';

void main() {
  testWidgets('Agendify abre na tela de login', (tester) async {
    await tester.pumpWidget(const AgendifyApp());
    expect(find.text('Entre na sua conta'), findsOneWidget);
  });
}
