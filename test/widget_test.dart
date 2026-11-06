
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:car_rental_management_system/main.dart';

void main() {
  testWidgets('Car Rental Login Screen Test',
          (WidgetTester tester) async {

        await tester.pumpWidget(const CarRentalApp());

        expect(find.text('Welcome Back!\nWe miss you :('),
            findsOneWidget);

        expect(find.byType(TextField), findsNWidgets(2));
      });
}
