import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_emergency/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AtlasApp());

    // Verify that the app launches and shows role selection screen
    expect(find.text('MediRescue'), findsOneWidget);
    expect(find.text('Emergency Medical Services'), findsOneWidget);
    expect(find.text('Select your role'), findsOneWidget);
    
    // Verify all three role options are present
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Hospital'), findsOneWidget);
    
    // Verify emergency button is present
    expect(find.text('EMERGENCY CALL'), findsOneWidget);
  });
}