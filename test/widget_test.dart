import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/configurations/app_config.dart';
import 'package:delivery_app/core/configurations/environment.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/main.dart';

void main() {
  testWidgets(
    'App launches and renders ShefsCloud Delivery splash screen',
    (WidgetTester tester) async {
      AppConfig.initialize(Environment.development);
      await sl.reset();
      await initServiceLocator();

      await tester.pumpWidget(const DeliveryApp());
      await tester.pump();

      expect(find.text('ShefsCloud Delivery'), findsOneWidget);
    },
  );
}
