import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('muestra el tablero principal', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyDietApp());
    await tester.pumpAndSettle();

    expect(find.text('MyDiet Kids'), findsOneWidget);
    expect(find.text('Resumen del dia'), findsOneWidget);
    expect(find.text('Registrar comida'), findsOneWidget);
  });
}
