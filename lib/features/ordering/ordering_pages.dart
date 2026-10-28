import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class FoodDetailPage extends StatefulWidget {
  final Food food;
  const FoodDetailPage({super.key, required this.food});
  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    final f = widget.food, s = AppScope.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFECEBEF),
              child: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.canPop(context)
                                ? Navigator.pop(context)
                                : home(context),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          const Expanded(
                            child: Text(
                              'Food Detail',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Favorite',
                            onPressed: () => s.toggleFavorite(f),
                            icon: Icon(
                              s.favorites.contains(f.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: s.favorites.contains(f.id) ? orange : ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
                    child: AssetImageView(
                      f.image,
                      height: 242,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          f.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RatingLabel(rating: f.rating),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ullamcorper imperdiet urna id non sed est sem. Rhoncus amet, enim purus gravida donec aliquet. Nibh sem tellus habitant.',
                    style: TextStyle(color: muted, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              money(f.price * quantity),
                              style: const TextStyle(
                                color: green,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      QuantityControl(
                        quantity: quantity,
                        minus: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                        plus: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: PrimaryButton(
            'Add to Cart',
            onPressed: () {
              s.add(f, quantity);
              go(context, '/cart');
            },
          ),
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final bool promo;
  const CartPage({super.key, this.promo = false});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final code = TextEditingController();
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'My Cart',
      bottom: s.cart.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OrderTotals(),
                const SizedBox(height: 20),
                PrimaryButton(
                  'Checkout',
                  onPressed: () => go(context, '/checkout'),
                ),
              ],
            ),
      child: Column(
        children: [
          if (s.cart.isEmpty)
            EmptyView(
              title: 'Your cart is empty',
              message: 'Find something delicious to start your order.',
              button: 'Explore food',
              onPressed: () => home(context),
            )
          else
            ...s.cart.entries.map((entry) {
              final f = foods.firstWhere((f) => f.id == entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: FoodRow(
                  f,
                  subtitle: '${entry.value}x',
                  trailing: QuantityControl(
                    quantity: entry.value,
                    minus: () => s.changeQuantity(f.id, -1),
                    plus: () => s.changeQuantity(f.id, 1),
                  ),
                ),
              );
            }),
          if (s.cart.isNotEmpty) ...[
            const SizedBox(height: 24),
            if (widget.promo)
              Surface(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: code,
                        decoration: const InputDecoration(
                          hintText: 'Promo Code',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(90, 34),
                        ),
                        onPressed: () {
                          if (code.text.trim().toUpperCase() != 'DELIVER10') {
                            toast(
                              context,
                              'Enter DELIVER10 for a demo discount',
                            );
                            return;
                          }
                          s.discount = true;
                          s.save();
                          toast(context, '10% discount applied');
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              )
            else
              TextButton(
                onPressed: () => go(context, '/cart-promo'),
                child: const Text('Have a promo code?'),
              ),
            if (s.discount)
              TextButton(
                onPressed: () {
                  s.discount = false;
                  s.save();
                },
                child: const Text('DELIVER10 applied · Remove'),
              ),
          ],
        ],
      ),
    );
  }
}

class OrderTotals extends StatelessWidget {
  const OrderTotals({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        _row('Subtotal', s.subtotal),
        _row('Delivery fee', s.deliveryFee),
        if (s.discount) _row('Discount', -s.savings),
        _row('Total', s.total, bold: true),
      ],
    );
  }

  Widget _row(String label, double amount, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: muted, fontSize: 14),
          ),
        ),
        Text(
          money(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class CheckoutPage extends StatefulWidget {
  final bool success;
  const CheckoutPage({super.key, this.success = false});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int method = 0;
  bool paying = false;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final checkout = PageFrame(
      title: 'Checkout',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: muted)),
              Text(
                money(
                  widget.success && s.orders.isNotEmpty
                      ? s.orders.first.total
                      : s.total,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            paying ? 'Processing...' : 'Pay',
            onPressed: paying || s.cart.isEmpty
                ? null
                : () async {
                    setState(() => paying = true);
                    await Future<void>.delayed(
                      const Duration(milliseconds: 400),
                    );
                    if (!context.mounted) return;
                    s.placeOrder();
                    Navigator.pushReplacementNamed(context, '/success');
                  },
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Address'),
          Surface(
            padding: const EdgeInsets.all(14),
            onTap: () => go(context, '/addresses'),
            child: Column(
              children: [
                const AssetImageView(
                  'address-map',
                  width: double.infinity,
                  height: 103,
                  radius: 8,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.address.detail,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => go(context, '/addresses'),
                      child: const Text('Edit', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionTitle('Payment Method'),
          for (int i = 0; i < 2; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: method == i ? orange : line),
                ),
                child: ListTile(
                  onTap: () => setState(() => method = i),
                  leading: i == 0
                      ? const Text(
                          'VISA',
                          style: TextStyle(
                            fontSize: 19,
                            color: Color(0xFF145C8E),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox(
                          width: 52,
                          child: Stack(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 32),
                              Positioned(
                                left: 18,
                                child: Icon(
                                  Icons.circle,
                                  color: orange,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                  title: const Text(
                    '•••• •••• •••• 87652',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    method == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: method == i ? orange : muted,
                    size: 22,
                  ),
                ),
              ),
            ),
          Surface(
            onTap: () => _addCard(context),
            child: const SizedBox(
              width: double.infinity,
              child: Text(
                '+ Add New',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Demo payment · No money will be charged.',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
    if (!widget.success) return checkout;
    return Stack(
      children: [
        checkout,
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.white54),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: green, size: 112),
                  const SizedBox(height: 36),
                  const Text(
                    'Your order was successfully\nreceived',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your meal is being prepared. Follow your\norder to see its delivery progress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12, height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 140,
                    child: PrimaryButton(
                      'Go It',
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/tracking'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addCard(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Demo payment methods'),
      content: const Text(
        'Visa and Mastercard sample cards are ready to use. Real card entry requires a payment provider.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Address',
      bottom: PrimaryButton(
        'Add a New Address',
        onPressed: () => go(context, '/new-address'),
      ),
      child: Column(
        children: List.generate(s.addresses.length, (i) {
          final a = s.addresses[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Surface(
              onTap: () {
                s.addressIndex = i;
                s.save();
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: pale,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on, color: muted),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.detail,
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                        const SizedBox(height: 4),
                        Text(a.phone, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    i == s.addressIndex
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: i == s.addressIndex ? orange : muted,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NewAddressPage extends StatefulWidget {
  const NewAddressPage({super.key});
  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      phone = TextEditingController(),
      detail = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    detail.dispose();
    super.dispose();
  }

  String? requiredField(String? v) =>
      v == null || v.trim().isEmpty ? 'Please fill in this field' : null;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'New Address',
    bottom: PrimaryButton(
      'Save',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        final s = AppScope.of(context);
        s.addresses.add(
          DeliveryAddress(
            name.text.trim(),
            phone.text.trim(),
            detail.text.trim(),
          ),
        );
        s.addressIndex = s.addresses.length - 1;
        s.save();
        Navigator.pop(context);
      },
    ),
    child: Form(
      key: form,
      child: Column(
        children: [
          LabeledField(
            'Full Name',
            hint: 'Brooklyn Simmons',
            controller: name,
            validator: requiredField,
          ),
          LabeledField(
            'Phone Number',
            hint: '(406) 555-0120',
            controller: phone,
            keyboardType: TextInputType.phone,
            validator: requiredField,
          ),
          LabeledField(
            'Detail Address',
            hint: '4517 Washington Ave.\nManchester, Kentucky 39495',
            controller: detail,
            lines: 6,
            validator: requiredField,
          ),
        ],
      ),
    ),
  );
}
