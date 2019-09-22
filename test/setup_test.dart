import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patchwork/pages/setup.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows building and interacting
  // with widgets in the test environment.
  https://medium.com/coding-with-flutter/flutter-unit-and-widget-tests-in-depth-b059b09bc692
  testWidgets('Setup has x', (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(Setup());

    

    // Create the Finders.
    final titleFinder = find.text('T');
    final messageFinder = find.text('M');

    // Use the `findsOneWidget` matcher provided by flutter_test to
    // verify that the Text widgets appear exactly once in the widget tree.
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}