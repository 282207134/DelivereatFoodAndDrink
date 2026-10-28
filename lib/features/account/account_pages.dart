import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class ProfilePage extends StatelessWidget {
  final bool logout;
  const ProfilePage({super.key, this.logout = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final profile = PageFrame(
      title: 'Profile',
      back: false,
      tab: 3,
      action: IconButton(
        tooltip: 'Edit Profile',
        onPressed: () => go(context, '/edit-profile'),
        icon: const Icon(Icons.edit_square, size: 21),
      ),
      child: Column(
        children: [
          const AssetImageView('avatar', width: 100, height: 100, radius: 50),
          const SizedBox(height: 16),
          Text(
            s.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(s.email, style: const TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 36),
          _heading('Account'),
          _item(context, Icons.person_outline, 'Member', '/member'),
          _item(context, Icons.lock_outline, 'Set Up a PIN', '/pin'),
          _item(context, Icons.shopping_bag_outlined, 'My Orders', '/orders'),
          _item(context, Icons.favorite_border, 'Wishlist', '/wishlist'),
          _item(
            context,
            Icons.location_on_outlined,
            'Saved Addresses',
            '/addresses',
          ),
          const SizedBox(height: 24),
          _heading('General'),
          _item(
            context,
            Icons.notifications_none,
            'Notification',
            '/notification-settings',
          ),
          _item(context, Icons.language, 'Language', '/language'),
          _item(
            context,
            Icons.delete_outline,
            'Clear Cache',
            null,
            onTap: () =>
                toast(context, 'Cache cleared. Your saved data is retained.'),
            trailing: '0 MB',
          ),
          const SizedBox(height: 24),
          _heading('About'),
          _item(
            context,
            Icons.shield_outlined,
            'Legal and Policies',
            '/privacy',
          ),
          _item(context, Icons.help_outline, 'Help & Feedback', '/help'),
          _item(context, Icons.info_outline, 'About Us', '/about'),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => go(context, '/logout'),
            child: const Text('Log Out'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    if (!logout) return profile;
    return Stack(
      children: [
        profile,
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
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.help_outline, color: orange, size: 80),
                  const SizedBox(height: 32),
                  const Text(
                    'ARE YOU SURE ?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'You can sign in again at any time. Your\nsaved favorites and addresses stay here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            s.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/welcome',
                              (r) => false,
                            );
                          },
                          child: const Text('Log Out'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(100, 52),
                          ),
                          onPressed: () => Navigator.canPop(context)
                              ? Navigator.pop(context)
                              : Navigator.pushReplacementNamed(
                                  context,
                                  '/profile',
                                ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heading(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        t,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
  );
  Widget _item(
    BuildContext c,
    IconData icon,
    String title,
    String? route, {
    VoidCallback? onTap,
    String? trailing,
  }) => InkWell(
    onTap: onTap ?? () => go(c, route!),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (trailing != null)
            Text(trailing, style: const TextStyle(fontSize: 11, color: muted))
          else
            const Icon(Icons.chevron_right, color: muted, size: 21),
        ],
      ),
    ),
  );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final s = AppScope.of(context);
      name.text = s.name;
      email.text = s.email;
      phone.text = s.phone;
      initialized = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Edit Profile',
    bottom: PrimaryButton(
      'Save Change',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        final s = AppScope.of(context);
        s.name = name.text.trim();
        s.email = email.text.trim();
        s.phone = phone.text.trim();
        s.save();
        toast(context, 'Profile updated');
        Navigator.pop(context);
      },
    ),
    child: Form(
      key: form,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const AssetImageView('avatar', width: 100, height: 100, radius: 50),
          TextButton(
            onPressed: () => toast(
              context,
              'The reference profile image is used in this demo.',
            ),
            child: const Text('Change image', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 32),
          LabeledField(
            'Name',
            controller: name,
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Enter your name' : null,
          ),
          LabeledField(
            'Email Address',
            controller: email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
                ? null
                : 'Enter a valid email address',
            suffix: const Icon(Icons.check_circle, color: green, size: 16),
          ),
          LabeledField(
            'Phone Number',
            controller: phone,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Enter a phone number' : null,
          ),
        ],
      ),
    ),
  );
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Language',
      child: Column(
        children: [
          _group(context, 'Suggested Languages', [
            'English (UK)',
            'English',
            'Bahasa Indonesia',
          ], s),
          const SizedBox(height: 32),
          _group(context, 'Other Languages', [
            'Chinese',
            'Croatian',
            'Czech',
            'Danish',
            'Filipino',
            'Finnish',
          ], s),
          const SizedBox(height: 20),
          const Text(
            'Your preference is saved. This UI kit uses English copy.',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _group(
    BuildContext c,
    String title,
    List<String> languages,
    AppState s,
  ) => Surface(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: muted)),
        const SizedBox(height: 8),
        ...languages.map(
          (l) => InkWell(
            onTap: () {
              s.language = l;
              s.save();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                border: l == languages.last
                    ? null
                    : const Border(bottom: BorderSide(color: line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l, style: const TextStyle(fontSize: 15)),
                  ),
                  if (l == s.language)
                    const Icon(Icons.check, color: green, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});
  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool exceptions = false;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Notification',
      child: Surface(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages Notifications',
              style: TextStyle(fontSize: 11, color: muted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Show Notifications')),
                Switch(
                  value: s.notifications,
                  activeThumbColor: orange,
                  onChanged: (v) {
                    s.notifications = v;
                    s.save();
                  },
                ),
              ],
            ),
            const Divider(),
            InkWell(
              onTap: () => setState(() => exceptions = !exceptions),
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Exceptions'),
                ),
              ),
            ),
            if (exceptions)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'No exceptions. Notifications are simulated locally.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Notification',
      back: false,
      child: Column(
        children: [
          if (!s.notifications)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Notifications are turned off in your settings.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          ...List.generate(
            3,
            (i) => InkWell(
              onTap: () => go(context, i == 0 ? '/history' : '/orders'),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodThumb(foods[0], size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [
                              'Your meal has been delivered. Enjoy your food!',
                              'Your order is being prepared by the restaurant.',
                              'Your previous order was cancelled.',
                            ][i],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '2 hours Ago',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ['Delivered', 'Pending', 'Cancel'][i],
                      style: TextStyle(
                        fontSize: 9,
                        color: [green, orange, Colors.redAccent][i],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  final String kind;
  const InfoPage({super.key, required this.kind});
  @override
  Widget build(BuildContext context) {
    if (kind == 'privacy') {
      return const PageFrame(
        title: 'Legal and Policies',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle('1. Terms'),
            Text(
              'DeliverEat is a local demonstration of the Pixso DeliverEat UI kit. The products, prices, delivery estimates, payment methods and driver conversations are sample data. No real orders or financial transactions are submitted.',
              style: TextStyle(color: muted, height: 1.8),
            ),
            SizedBox(height: 28),
            SectionTitle('2. Your information'),
            Text(
              'Profile, addresses, favorites, cart, orders and preferences are stored on this device. They are not sent to a server. Demo passwords and PINs remain in memory for this session and are never saved to local preferences.',
              style: TextStyle(color: muted, height: 1.8),
            ),
            SizedBox(height: 28),
            SectionTitle('Changes to the Service and/or Terms'),
            Text(
              'A production release requires a server, secure authentication, a payment provider, map services and a reviewed privacy policy. This information describes the current demonstration only.',
              style: TextStyle(color: muted, height: 1.8),
            ),
          ],
        ),
      );
    }
    return PageFrame(
      title: kind == 'about'
          ? 'About Us'
          : kind == 'help'
          ? 'Help & Feedback'
          : 'Member',
      child: Column(
        children: [
          Icon(
            kind == 'about'
                ? Icons.fastfood
                : kind == 'help'
                ? Icons.help_outline
                : Icons.person_outline,
            color: orange,
            size: 72,
          ),
          const SizedBox(height: 24),
          Text(
            kind == 'about'
                ? 'DeliverEat'
                : kind == 'help'
                ? 'How can we help?'
                : 'DeliverEat Member',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            kind == 'about'
                ? 'Food & drink, delivered.\nFlutter implementation of the DeliverEat UI kit.\nVersion 1.0.0'
                : kind == 'help'
                ? 'Browse food, add it to your cart and try the demo checkout.\n\nVerification code: 1234\nPromo code: DELIVER10\n\nNo real payment or delivery is performed.'
                : 'Your favorites, addresses and orders\nare saved on this device.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.8),
          ),
          const SizedBox(height: 32),
          if (kind == 'about')
            PrimaryButton(
              'Explore all screens',
              onPressed: () => go(context, '/screens'),
            ),
          if (kind == 'help')
            PrimaryButton(
              'View My Orders',
              onPressed: () => go(context, '/orders'),
            ),
          if (kind == 'member')
            PrimaryButton(
              'Edit Profile',
              onPressed: () => go(context, '/edit-profile'),
            ),
        ],
      ),
    );
  }
}

class ScreenGalleryPage extends StatelessWidget {
  const ScreenGalleryPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Screen Library · 47',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Every mobile frame in the Pixso reference.\nPages use your current local demo data.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 24),
        for (final group in screenSpecs.map((s) => s.group).toSet()) ...[
          SectionTitle(group),
          ...screenSpecs
              .where((s) => s.group == group)
              .map(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.title, style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                    'Pixso ${s.node}',
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => go(context, s.route),
                ),
              ),
          const SizedBox(height: 24),
        ],
      ],
    ),
  );
}
