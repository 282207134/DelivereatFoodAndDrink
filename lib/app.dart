import 'package:flutter/material.dart';

import 'data/app_state.dart';
import 'data/catalog.dart';
import 'features/auth/auth_pages.dart';
import 'features/discover/discover_pages.dart';
import 'features/ordering/ordering_pages.dart';
import 'features/delivery/delivery_pages.dart';
import 'features/account/account_pages.dart';
import 'ui/theme.dart';

class DeliverEatApp extends StatelessWidget {
  final AppState state;
  final String initialRoute;
  final bool preview;
  final GlobalKey<NavigatorState>? navigatorKey;
  const DeliverEatApp({
    super.key,
    required this.state,
    this.initialRoute = '/splash',
    this.preview = false,
    this.navigatorKey,
  });
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      title: 'DeliverEat',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (name) => [_route(RouteSettings(name: name))],
      onGenerateRoute: _route,
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFF5F5F7),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child!,
          ),
        ),
      ),
    ),
  );
  Route<dynamic> _route(RouteSettings settings) => MaterialPageRoute(
    settings: settings,
    builder: (context) => _page(settings),
  );
  Widget _page(RouteSettings settings) {
    final name = settings.name ?? '/home';
    if (name.startsWith('/onboarding/')) {
      final parts = name.split('/');
      return OnboardingPage(
        version: int.tryParse(parts.elementAtOrNull(2) ?? '') ?? 1,
        step: int.tryParse(parts.elementAtOrNull(3) ?? '') ?? 0,
      );
    }
    return switch (name) {
      '/splash' => SplashPage(preview: preview),
      '/welcome' => const WelcomePage(),
      '/login' => const AuthPage(mode: AuthMode.login),
      '/register' => const AuthPage(mode: AuthMode.register),
      '/reset' => const AuthPage(mode: AuthMode.reset),
      '/new-password' => const AuthPage(mode: AuthMode.newPassword),
      '/verification' => CodePage(
        mode: CodeMode.verification,
        flow: settings.arguments as String? ?? 'reset',
      ),
      '/home' => const HomePage(),
      '/search' => const SearchPage(),
      '/filter' => const SearchPage(filterInitially: true),
      '/food' => FoodDetailPage(
        food: settings.arguments as Food? ?? foods.first,
      ),
      '/cart' => const CartPage(),
      '/cart-promo' => const CartPage(promo: true),
      '/checkout' => const CheckoutPage(),
      '/success' => const CheckoutPage(success: true),
      '/addresses' => const AddressesPage(),
      '/new-address' => const NewAddressPage(),
      '/vouchers' => const VouchersPage(),
      '/promo' => const CollectionsPage(),
      '/wishlist' => const CollectionsPage(wishlist: true),
      '/orders' => const OrdersPage(),
      '/history' => const OrdersPage(history: true),
      '/tracking' => const MapPage(tracking: true),
      '/chat' => const ChatPage(),
      '/rating' => const RatingPage(),
      '/restaurants' => const SearchPage(restaurantsOnly: true),
      '/restaurant-filter' => const SearchPage(
        restaurantsOnly: true,
        filterInitially: true,
      ),
      '/restaurant' => RestaurantPage(
        restaurant: settings.arguments as Restaurant? ?? restaurants.first,
      ),
      '/maps' => MapPage(
        restaurant: settings.arguments as Restaurant? ?? restaurants.first,
      ),
      '/profile' => const ProfilePage(),
      '/edit-profile' => const EditProfilePage(),
      '/privacy' => const InfoPage(kind: 'privacy'),
      '/language' => const LanguagePage(),
      '/notification-settings' => const NotificationSettingsPage(),
      '/notifications' => const NotificationsPage(),
      '/logout' => const ProfilePage(logout: true),
      '/pin' => const CodePage(mode: CodeMode.pin),
      '/confirm-pin' => const CodePage(mode: CodeMode.confirmPin),
      '/screens' => const ScreenGalleryPage(),
      '/about' => const InfoPage(kind: 'about'),
      '/help' => const InfoPage(kind: 'help'),
      '/member' => const InfoPage(kind: 'member'),
      _ => const HomePage(),
    };
  }
}
