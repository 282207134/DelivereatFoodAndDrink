import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';
import '../discover/discover_pages.dart';

class OrdersPage extends StatelessWidget {
  final bool history;
  const OrdersPage({super.key, this.history = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final orders = s.orders
        .where(
          (o) => history
              ? o.status == 'Delivered' || o.status == 'Cancelled'
              : o.status == 'On the Way',
        )
        .toList();
    return PageFrame(
      title: 'My Orders',
      child: Column(
        children: [
          Surface(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _tab(context, 'Upcoming', !history, '/orders'),
                _tab(context, 'History', history, '/history'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (orders.isEmpty)
            EmptyView(
              title: history ? 'No past orders yet' : 'No upcoming orders',
              message: history
                  ? 'Your completed orders will appear here.'
                  : 'Order your favorites and follow their journey.',
              button: 'Discover food',
              onPressed: () => home(context),
            ),
          ...orders.map((o) {
            final f = foods.firstWhere((f) => f.id == o.items.keys.first);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Surface(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        FoodThumb(f),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.shortName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${o.items.values.fold(0, (a, b) => a + b)}x',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                money(o.total),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '#${o.id}',
                          style: const TextStyle(color: orange, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suggested Arrived',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                        Text(
                          'Now',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '24',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' min',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          o.status,
                          style: TextStyle(
                            color: o.status == 'Delivered'
                                ? green
                                : o.status == 'Cancelled'
                                ? Colors.redAccent
                                : ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: history && o.status == 'Cancelled'
                              ? const SizedBox()
                              : TextButton(
                                  onPressed: () => history
                                      ? _reorder(context, o)
                                      : _cancel(context, o),
                                  child: Text(history ? 'Reorder' : 'Cancel'),
                                ),
                        ),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(100, 42),
                            ),
                            onPressed: () {
                              if (o.status == 'Cancelled') {
                                _reorder(context, o);
                                return;
                              }
                              s.selectedOrderId = o.id;
                              go(context, history ? '/rating' : '/tracking');
                            },
                            child: Text(
                              o.status == 'Cancelled'
                                  ? 'Reorder'
                                  : history
                                  ? 'Rate Order'
                                  : 'Detail Order',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String title, bool active, String route) =>
      Expanded(
        child: active
            ? FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(100, 48)),
                onPressed: () {},
                child: Text(title),
              )
            : TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, route),
                child: Text(title),
              ),
      );
  void _reorder(BuildContext context, DemoOrder o) {
    final s = AppScope.of(context);
    for (final e in o.items.entries) {
      s.add(foods.firstWhere((f) => f.id == e.key), e.value);
    }
    go(context, '/cart');
  }

  void _cancel(BuildContext context, DemoOrder o) => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Cancel your order?'),
      content: const Text('This demo order will move to your history.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Keep order'),
        ),
        TextButton(
          onPressed: () {
            o.status = 'Cancelled';
            AppScope.of(context).save();
            Navigator.pop(c);
          },
          child: const Text('Cancel order'),
        ),
      ],
    ),
  );
}

class MapPage extends StatelessWidget {
  final bool tracking;
  final Restaurant restaurant;
  const MapPage({
    super.key,
    this.tracking = false,
    this.restaurant = const Restaurant('Gionino Restaurant', 'restaurant'),
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        const AssetImageView('map'),
        const CustomPaint(painter: _RoutePainter()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Back',
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () => Navigator.canPop(context)
                      ? Navigator.pop(context)
                      : home(context),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton.filledTonal(
                  tooltip: 'Map details',
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delivery map'),
                      content: const Text(
                        'This is the map artwork from Pixso. The route and delivery time are demo data.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.sizeOf(context).height * .14,
          left: MediaQuery.sizeOf(context).width * .34,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('1.25 km', style: TextStyle(fontSize: 12)),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: tracking
              ? _tracking(context)
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: RestaurantRow(
                      restaurant,
                      trailing: IconButton(
                        tooltip: 'Close map',
                        onPressed: () => Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : home(context),
                        icon: const Icon(Icons.cancel, color: orange, size: 32),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
  Widget _tracking(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AssetImageView('driver', width: 56, height: 56, radius: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Justin Kenter',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Driver – B 678 EA',
                      style: TextStyle(color: green, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Chat with driver',
                onPressed: () => go(context, '/chat'),
                icon: const Icon(Icons.sms, color: orange),
              ),
              IconButton(
                tooltip: 'Call driver',
                onPressed: () => toast(context, 'Demo: calling Justin Kenter…'),
                icon: const Icon(Icons.call, color: orange),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _timeline(Icons.schedule, 'Estimated Time', '25 Minute'),
          const SizedBox(height: 24),
          _timeline(
            Icons.location_on_outlined,
            'Jl. Veteran No. 4 Surabaya',
            'Home | 14:30',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            'Order Received',
            onPressed: () {
              AppScope.of(context).setOrderStatus('Delivered');
              Navigator.pushReplacementNamed(context, '/rating');
            },
          ),
        ],
      ),
    ),
  );
  Widget _timeline(IconData icon, String title, String subtitle) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: pale, shape: BoxShape.circle),
        child: Icon(icon, color: muted, size: 21),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: muted)),
          ],
        ),
      ),
    ],
  );
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(size.width * .42, size.height * .20)
      ..lineTo(size.width * .25, size.height * .20)
      ..lineTo(size.width * .21, size.height * .38)
      ..lineTo(size.width * .62, size.height * .39)
      ..lineTo(size.width * .62, size.height * .51);
    canvas.drawPath(
      p,
      Paint()
        ..color = orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    for (final o in [
      Offset(size.width * .42, size.height * .20),
      Offset(size.width * .62, size.height * .51),
    ]) {
      canvas.drawCircle(o, 10, Paint()..color = orange);
      canvas.drawCircle(o, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController(), scroll = ScrollController();
  final messages = <({String text, bool mine})>[
    (text: 'I got it. food will arrive at\n9 am.', mine: false),
    (text: 'Thank you and order me a\nmeal by 9 am.', mine: true),
    (text: 'Oke..', mine: false),
  ];
  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    if (controller.text.trim().isEmpty) return;
    setState(() => messages.add((text: controller.text.trim(), mine: true)));
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFECEBEF),
    appBar: AppBar(
      backgroundColor: const Color(0xFFECEBEF),
      title: const Text('Driver – B 678 EA'),
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () =>
            Navigator.canPop(context) ? Navigator.pop(context) : home(context),
        icon: const Icon(Icons.chevron_left),
      ),
      actions: [
        IconButton(
          tooltip: 'Call driver',
          onPressed: () => toast(context, 'Demo: calling Justin Kenter…'),
          icon: const Icon(Icons.call, color: orange),
        ),
      ],
    ),
    body: Column(
      children: [
        const SizedBox(height: 8),
        const AssetImageView('driver', width: 100, height: 100, radius: 50),
        const SizedBox(height: 12),
        const Text(
          'Justin Kenter',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Online',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.all(24),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                          mainAxisAlignment: m.mine
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!m.mine) ...[
                              const AssetImageView(
                                'driver',
                                width: 30,
                                height: 30,
                                radius: 15,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: m.mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 240,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: m.mine
                                          ? orange
                                          : const Color(0xFFECEBEF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      m.text,
                                      style: TextStyle(
                                        color: m.mine ? Colors.white : ink,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '15:42',
                                    style: TextStyle(fontSize: 9, color: muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: TextField(
                      controller: controller,
                      onSubmitted: (_) => send(),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        fillColor: pale,
                        prefixIcon: const Icon(
                          Icons.sentiment_satisfied_alt,
                          color: muted,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'Send message',
                          onPressed: send,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: orange,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int rating = 4;
  bool photo = false;
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = AppScope.of(context).activeOrder;
    final food = foods.firstWhere(
      (f) => f.id == order?.items.keys.first,
      orElse: () => foods.first,
    );
    return PageFrame(
      title: 'Rating',
      bottom: PrimaryButton(
        'Submit Review',
        onPressed: () {
          final state = AppScope.of(context);
          state.reviews.add({
            'order': state.activeOrder?.id,
            'rating': rating,
            'comment': text.text.trim(),
            'demoPhoto': photo,
          });
          state.setOrderStatus('Delivered');
          state.save();
          toast(context, 'Thank you! Your demo review was submitted.');
          Navigator.pushNamedAndRemoveUntil(context, '/history', (r) => false);
        },
      ),
      child: Column(
        children: [
          FoodRow(food, subtitle: '${order?.items[food.id] ?? 1}x'),
          const SizedBox(height: 28),
          Icon(
            rating >= 4
                ? Icons.sentiment_very_satisfied
                : rating >= 3
                ? Icons.sentiment_satisfied
                : Icons.sentiment_dissatisfied,
            color: orange,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            rating >= 4
                ? 'Satisfied'
                : rating >= 3
                ? 'Good'
                : 'Could be better',
            style: const TextStyle(color: orange, fontSize: 11),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your overall rating this food',
            style: TextStyle(color: muted, fontSize: 11),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                tooltip: 'Rate ${i + 1} stars',
                onPressed: () => setState(() => rating = i + 1),
                icon: Icon(
                  Icons.star_rounded,
                  size: 36,
                  color: i < rating ? orange : pale,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Surface(
            onTap: () => setState(() => photo = !photo),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  photo ? Icons.check_circle_outline : Icons.add,
                  color: orange,
                ),
                const SizedBox(width: 8),
                Text(
                  photo ? 'Demo photo attached' : 'Add photo',
                  style: const TextStyle(color: orange),
                ),
              ],
            ),
          ),
          if (photo)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: AssetImageView('burger', height: 80, fit: BoxFit.contain),
            ),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What did you like?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: text,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Tell me your experience.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
