import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivereat/app.dart';
import 'package:delivereat/data/app_state.dart';
import 'package:delivereat/data/catalog.dart';
import 'package:delivereat/features/discover/discover_pages.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture every Pixso screen on Android', (tester) async {
    final warmup = AppState();
    await tester.pumpWidget(
      DeliverEatApp(state: warmup, initialRoute: '/home', preview: true),
    );
    await tester.pumpAndSettle();
    final imageContext = tester.element(find.byType(Scaffold).first);
    for (final name in [
      'address-map',
      'avatar',
      'burger',
      'coffee',
      'driver',
      'logo-white',
      'map',
      'noodles',
      'pizza',
      'restaurant',
      'restaurant2',
      'restaurant3',
      'restaurant4',
      'voucher',
      'voucher2',
      for (int v = 1; v <= 3; v++)
        for (int n = 1; n <= 3; n++) 'onboarding$v-$n',
    ]) {
      await tester.runAsync(
        () =>
            precacheImage(AssetImage('assets/images/$name.png'), imageContext),
      );
    }
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    const selected = String.fromEnvironment('CAPTURE_PREFIX');
    for (final spec in screenSpecs.where(
      (s) =>
          selected.isEmpty ||
          selected.split(',').any((prefix) => s.route.startsWith(prefix)),
    )) {
      final state = AppState()..seedPreview();
      if (spec.route == '/cart-promo') state.cart.remove('coffee');
      await tester.pumpWidget(
        DeliverEatApp(
          key: ValueKey(spec.route),
          state: state,
          initialRoute: spec.route,
          preview: true,
        ),
      );
      await tester.pumpAndSettle();
      for (final element in find.byType(Image).evaluate()) {
        final widget = element.widget as Image;
        await precacheImage(widget.image, element);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: spec.route);
      if (spec.route == '/maps') {
        expect(
          tester.getSize(find.byType(RestaurantRow)).height,
          lessThan(140),
        );
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)),
      );
      await tester.pump();
      await binding.takeScreenshot(spec.node.replaceAll(':', '-'));
      if (spec.route == '/home' || spec.route == '/profile') {
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -650),
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot(
          '${spec.node.replaceAll(':', '-')}-bottom',
        );
      }
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    }
  });
}
