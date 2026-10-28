import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

class DeliveryAddress {
  final String name, phone, detail;
  const DeliveryAddress(this.name, this.phone, this.detail);
  Map<String, String> toJson() => {
    'name': name,
    'phone': phone,
    'detail': detail,
  };
  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(json['name'], json['phone'], json['detail']);
}

class DemoOrder {
  final String id;
  final Map<String, int> items;
  final double total;
  String status;
  DemoOrder(this.id, this.items, this.total, {this.status = 'On the Way'});
  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items,
    'total': total,
    'status': status,
  };
  factory DemoOrder.fromJson(Map<String, dynamic> j) => DemoOrder(
    j['id'],
    Map<String, int>.from(j['items']),
    (j['total'] as num).toDouble(),
    status: j['status'],
  );
}

/// Local demo repository and observable state. No network or payment is performed.
class AppState extends ChangeNotifier {
  final SharedPreferences? preferences;
  AppState({this.preferences});
  SharedPreferences? _prefs;
  Map<String, int> cart = {};
  Set<String> favorites = {};
  List<DeliveryAddress> addresses = [
    const DeliveryAddress(
      'Jane Cooper',
      '(406) 555-0120',
      '4517 Washington Ave.\nManchester, Kentucky 39495',
    ),
    const DeliveryAddress(
      'Brooklyn Simmons',
      '+62 3712 3789 542',
      'Dominic Street\nCaledon, sector 43 UK',
    ),
    const DeliveryAddress(
      'Jane Cooper',
      '(406) 555-0120',
      'Jl. Veteran No. 4\nSurabaya, Indonesia',
    ),
  ];
  List<DemoOrder> orders = [];
  int addressIndex = 1;
  String name = 'Brooklyn Simmons',
      email = 'Brooklynsimmons@gmail.com',
      phone = '+62 3712 3789 542';
  String language = 'English (UK)', category = '', distance = '';
  String? selectedOrderId;
  DemoOrder? get activeOrder =>
      orders.where((o) => o.id == selectedOrderId).firstOrNull ??
      orders.firstOrNull;
  List<Map<String, dynamic>> reviews = [];
  int minimumRating = 0;
  bool notifications = true,
      signedIn = false,
      onboarded = false,
      voucherClaimed = false,
      discount = false;
  String? pendingPin, pin, password;
  DeliveryAddress get address =>
      addresses[addressIndex.clamp(0, addresses.length - 1)];
  double get subtotal => cart.entries.fold(
    0,
    (sum, e) => sum + foods.firstWhere((f) => f.id == e.key).price * e.value,
  );
  double get deliveryFee => cart.isEmpty ? 0 : 2.10;
  double get savings => discount ? (subtotal * 10).round() / 100 : 0;
  double get total => ((subtotal + deliveryFee - savings) * 100).round() / 100;
  bool matchesDistance(double km) => switch (distance) {
    '< 5KM' => km < 5,
    '5KM - 10 KM' => km >= 5 && km <= 10,
    '> 10KM' => km > 10,
    _ => true,
  };
  int get cartCount => cart.values.fold(0, (a, b) => a + b);
  Future<void> load() async {
    _prefs = preferences ?? await SharedPreferences.getInstance();
    final raw = _prefs!.getString('delivereat.state');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      cart = Map<String, int>.from(j['cart'] ?? {});
      favorites = Set<String>.from(j['favorites'] ?? []);
      name = j['name'] ?? name;
      email = j['email'] ?? email;
      phone = j['phone'] ?? phone;
      language = j['language'] ?? language;
      notifications = j['notifications'] ?? true;
      signedIn = j['signedIn'] ?? false;
      onboarded = j['onboarded'] ?? false;
      voucherClaimed = j['voucherClaimed'] ?? false;
      discount = j['discount'] ?? false;
      addressIndex = j['addressIndex'] ?? 0;
      reviews = (j['reviews'] as List? ?? [])
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      if (j['addresses'] != null) {
        addresses = (j['addresses'] as List)
            .map((a) => DeliveryAddress.fromJson(a))
            .toList();
      }
      if (addresses.isEmpty) {
        addresses = [
          const DeliveryAddress('Home', '', 'Dominic Street, Caledon'),
        ];
      }
      orders = (j['orders'] as List? ?? [])
          .map((o) => DemoOrder.fromJson(o))
          .toList();
    } on FormatException {
      /* Ignore an interrupted local snapshot. */
    }
  }

  Future<void> save() async {
    notifyListeners();
    await _prefs?.setString(
      'delivereat.state',
      jsonEncode({
        'cart': cart,
        'favorites': favorites.toList(),
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'orders': orders.map((o) => o.toJson()).toList(),
        'addressIndex': addressIndex,
        'name': name,
        'email': email,
        'phone': phone,
        'language': language,
        'notifications': notifications,
        'signedIn': signedIn,
        'onboarded': onboarded,
        'voucherClaimed': voucherClaimed,
        'discount': discount,
        'reviews': reviews,
      }),
    );
  }

  void add(Food food, [int quantity = 1]) {
    cart[food.id] = (cart[food.id] ?? 0) + quantity;
    save();
  }

  void changeQuantity(String id, int delta) {
    final count = (cart[id] ?? 0) + delta;
    if (count <= 0) {
      cart.remove(id);
    } else {
      cart[id] = count;
    }
    save();
  }

  void toggleFavorite(Food food) {
    if (!favorites.add(food.id)) favorites.remove(food.id);
    save();
  }

  void applyFilters(String c, String d, int r) {
    category = c;
    distance = d;
    minimumRating = r;
    notifyListeners();
  }

  void clearFilters() {
    category = '';
    distance = '';
    minimumRating = 0;
    notifyListeners();
  }

  void placeOrder() {
    if (cart.isEmpty) return;
    orders.insert(
      0,
      DemoOrder('${234556 + orders.length}', Map.of(cart), total),
    );
    selectedOrderId = orders.first.id;
    cart.clear();
    discount = false;
    save();
  }

  void setOrderStatus(String status) {
    if (orders.isNotEmpty) {
      orders
              .firstWhere(
                (o) => o.id == selectedOrderId,
                orElse: () => orders.first,
              )
              .status =
          status;
      save();
    }
  }

  void signOut() {
    signedIn = false;
    password = null;
    pin = null;
    save();
  }

  void seedPreview() {
    cart = {for (final f in foods) f.id: 1};
    favorites = {'burger', 'pizza'};
    orders = [
      DemoOrder('234556', {'burger': 2}, 22.34),
      DemoOrder('234555', {'pizza': 2}, 28.34, status: 'Delivered'),
    ];
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
