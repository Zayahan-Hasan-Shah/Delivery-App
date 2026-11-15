import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/configurations/app_config.dart';
import 'package:delivery_app/core/configurations/environment.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/main.dart';

void main() {
  testWidgets('App launches and renders splash screen smoke test', (WidgetTester tester) async {
    AppConfig.initialize(Environment.development);
    await initServiceLocator();

    await tester.pumpWidget(const DeliveryApp());

    // Verify splash branding is rendered
    expect(find.text('LogiFlow Delivery'), findsOneWidget);
  });
}
