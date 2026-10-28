import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivereat/data/app_state.dart';
import 'package:delivereat/data/catalog.dart';

void main() {
  test(
    'delivery updates the selected order and distance filters use catalog data',
    () {
      final s = AppState()..seedPreview();
      s.selectedOrderId = '234555';
      s.setOrderStatus('Cancelled');
      expect(s.orders.first.status, 'On the Way');
      expect(s.orders.last.status, 'Cancelled');
      s.applyFilters('Pizza', '5KM - 10 KM', 4);
      expect(s.matchesDistance(6.5), true);
      expect(s.matchesDistance(1.25), false);
      s.clearFilters();
      expect(s.matchesDistance(1.25), true);
    },
  );
  test('cart arithmetic, discounts and immutable order snapshot', () {
    final s = AppState();
    s.add(foods[0], 2);
    s.add(foods[1]);
    expect(s.subtotal, closeTo(33.36, .001));
    s.discount = true;
    expect(s.total, closeTo(32.12, .001));
    s.placeOrder();
    expect(s.cart, isEmpty);
    expect(s.orders.single.items, {'burger': 2, 'pizza': 1});
    s.add(foods[0]);
    expect(s.orders.single.items['burger'], 2);
    s.changeQuantity('burger', -1);
    expect(s.cart, isEmpty);
    expect(s.total, 0);
  });
  test(
    'profile, favorites, cart, addresses and order survive reload',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final s = AppState(preferences: prefs);
      await s.load();
      s.name = 'Alex';
      s.add(foods[0]);
      s.toggleFavorite(foods[1]);
      s.placeOrder();
      s.addresses.add(const DeliveryAddress('Alex', '12345', 'New street'));
      s.addressIndex = 3;
      s.notifications = false;
      await s.save();
      final restored = AppState(preferences: prefs);
      await restored.load();
      expect(restored.name, 'Alex');
      expect(restored.favorites, {'pizza'});
      expect(restored.orders.single.items, {'burger': 1});
      expect(restored.address.detail, 'New street');
      expect(restored.notifications, false);
    },
  );
}
