class Food {
  final String id, name, image, category;
  final double price, rating;
  final double distance;
  const Food(
    this.id,
    this.name,
    this.image,
    this.category,
    this.price, {
    this.rating = 4.5,
    this.distance = 1.25,
  });
  String get shortName =>
      name == 'Beef Burger with Cheese' ? 'Beef Burger' : name;
}

const foods = [
  Food('burger', 'Beef Burger with Cheese', 'burger', 'Burger', 10.12),
  Food('pizza', 'Italian Pizza', 'pizza', 'Pizza', 13.12),
  Food('noodles', 'Noodles', 'noodles', 'Noodle', 8.12),
  Food('coffee', 'Arabica Coffee', 'coffee', 'Coffee', 9.12),
];

class Restaurant {
  final String name, image;
  final bool open;
  final double distance;
  final String category;
  const Restaurant(
    this.name,
    this.image, {
    this.open = true,
    this.distance = 1.25,
    this.category = 'Burger',
  });
}

const restaurants = [
  Restaurant('Gionino Restaurant', 'restaurant'),
  Restaurant(
    'Veteran Restaurant',
    'restaurant2',
    distance: 6.5,
    category: 'Pizza',
  ),
  Restaurant(
    'Marbela Restaurant',
    'restaurant3',
    distance: 3.2,
    category: 'Chicken',
  ),
  Restaurant(
    'Le Smar Restaurant',
    'restaurant4',
    distance: 12.4,
    category: 'Sushi',
  ),
  Restaurant(
    'Pizza Hit',
    'restaurant2',
    open: false,
    distance: 8.3,
    category: 'Pizza',
  ),
];
String money(double value) => '\$${value.toStringAsFixed(2)}';

class ScreenSpec {
  final String route, title, node, group;
  const ScreenSpec(this.route, this.title, this.node, this.group);
}

const screenSpecs = [
  ScreenSpec('/splash', 'Splash Screen', '169:2157', 'Authentication'),
  ScreenSpec('/onboarding/1/0', 'Onboarding v1 · 1', '157:276', 'Onboarding'),
  ScreenSpec('/onboarding/1/1', 'Onboarding v1 · 2', '157:355', 'Onboarding'),
  ScreenSpec('/onboarding/1/2', 'Onboarding v1 · 3', '157:314', 'Onboarding'),
  ScreenSpec('/onboarding/2/0', 'Onboarding v2 · 1', '148:287', 'Onboarding'),
  ScreenSpec('/onboarding/2/1', 'Onboarding v2 · 2', '148:299', 'Onboarding'),
  ScreenSpec('/onboarding/2/2', 'Onboarding v2 · 3', '148:273', 'Onboarding'),
  ScreenSpec('/onboarding/3/0', 'Onboarding v3 · 1', '164:228', 'Onboarding'),
  ScreenSpec('/onboarding/3/1', 'Onboarding v3 · 2', '175:408', 'Onboarding'),
  ScreenSpec('/onboarding/3/2', 'Onboarding v3 · 3', '175:428', 'Onboarding'),
  ScreenSpec('/welcome', 'Log in / Sign up', '54:228', 'Authentication'),
  ScreenSpec('/login', 'Sign In', '54:81', 'Authentication'),
  ScreenSpec('/register', 'Register', '54:145', 'Authentication'),
  ScreenSpec('/reset', 'Reset Password', '54:182', 'Authentication'),
  ScreenSpec('/verification', 'Verification', '54:242', 'Authentication'),
  ScreenSpec(
    '/new-password',
    'Create New Password',
    '54:198',
    'Authentication',
  ),
  ScreenSpec('/home', 'Home', '101:1708', 'Ordering'),
  ScreenSpec('/search', 'Search', '76:400', 'Ordering'),
  ScreenSpec('/filter', 'Filter', '169:1132', 'Ordering'),
  ScreenSpec('/food', 'Food Detail', '58:174', 'Ordering'),
  ScreenSpec('/cart', 'Cart', '59:223', 'Ordering'),
  ScreenSpec('/cart-promo', 'Cart · Promo', '91:1288', 'Ordering'),
  ScreenSpec('/checkout', 'Checkout', '76:116', 'Ordering'),
  ScreenSpec('/success', 'Checkout · Success', '81:323', 'Ordering'),
  ScreenSpec('/addresses', 'Address', '82:406', 'Ordering'),
  ScreenSpec('/new-address', 'New Address', '82:604', 'Ordering'),
  ScreenSpec('/vouchers', 'Vouchers', '87:351', 'Ordering'),
  ScreenSpec('/promo', 'Promo', '87:453', 'Ordering'),
  ScreenSpec('/wishlist', 'Wishlist', '91:704', 'Ordering'),
  ScreenSpec('/notifications', 'Notification', '91:1038', 'Ordering'),
  ScreenSpec('/orders', 'Order Upcoming', '91:1400', 'Orders'),
  ScreenSpec('/history', 'Order History', '126:671', 'Orders'),
  ScreenSpec('/tracking', 'Tracking Order', '61:163', 'Delivery'),
  ScreenSpec('/chat', 'Chat', '61:573', 'Delivery'),
  ScreenSpec('/rating', 'Rating', '71:116', 'Delivery'),
  ScreenSpec('/restaurants', 'Restaurant Nearby', '95:114', 'Restaurants'),
  ScreenSpec(
    '/restaurant-filter',
    'Restaurant Filter',
    '169:1466',
    'Restaurants',
  ),
  ScreenSpec('/restaurant', 'Restaurant Detail', '95:488', 'Restaurants'),
  ScreenSpec('/maps', 'Maps', '95:1231', 'Restaurants'),
  ScreenSpec('/profile', 'Profile', '128:170', 'Account'),
  ScreenSpec('/edit-profile', 'Edit Profile', '62:434', 'Account'),
  ScreenSpec('/privacy', 'Legal and Policies', '79:126', 'Account'),
  ScreenSpec('/language', 'Language', '79:145', 'Account'),
  ScreenSpec(
    '/notification-settings',
    'Notification Settings',
    '79:187',
    'Account',
  ),
  ScreenSpec('/logout', 'Log Out', '82:114', 'Account'),
  ScreenSpec('/pin', 'Set Up a PIN', '128:296', 'Account'),
  ScreenSpec('/confirm-pin', 'Confirm a PIN', '128:370', 'Account'),
];
