import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivereat/app.dart';
import 'package:delivereat/data/app_state.dart';
import 'package:delivereat/data/catalog.dart';

void main() {
  for (final spec in screenSpecs) {
    testWidgets('375×812: ${spec.title} (${spec.node})', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = AppState()..seedPreview();
      await tester.pumpWidget(
        DeliverEatApp(state: state, initialRoute: spec.route, preview: true),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: spec.route);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
  testWidgets('add to cart → checkout → pay → receive → review', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState();
    await tester.pumpWidget(
      DeliverEatApp(state: state, initialRoute: '/food', preview: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();
    expect(state.cart, {'burger': 1});
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();
    expect(state.orders, hasLength(1));
    expect(state.cart, isEmpty);
    await tester.tap(find.text('Go It'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Order Received'));
    await tester.pumpAndSettle();
    expect(state.orders.single.status, 'Delivered');
    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();
    expect(find.text('My Orders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search and favorites react to user input', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      DeliverEatApp(state: state, initialRoute: '/search', preview: true),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pizza');
    await tester.pumpAndSettle();
    expect(find.text('Italian Pizza'), findsOneWidget);
    expect(find.text('Beef Burger'), findsNothing);
    state.toggleFavorite(foods[1]);
    await tester.pumpAndSettle();
    expect(state.favorites, {'pizza'});
  });
}
