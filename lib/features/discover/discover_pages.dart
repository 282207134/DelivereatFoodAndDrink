import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      bottomNavigationBar: const BottomTabs(index: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.paddingOf(context).top + 163,
                  color: orange,
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => go(context, '/addresses'),
                                child: Text(
                                  s.address.detail.replaceAll('\n', ' '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              tooltip: 'Notifications',
                              onPressed: () => go(context, '/notifications'),
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => go(context, '/promo'),
                          child: Container(
                            height: 148,
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -26,
                                  top: -55,
                                  child: AssetImageView(
                                    'pizza',
                                    width: 215,
                                    height: 215,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '50%',
                                        style: TextStyle(
                                          color: green,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Off the full price\nof Italian Pizza\nfood',
                                        style: TextStyle(
                                          color: muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Positioned(
                                  bottom: 14,
                                  left: 148,
                                  child: Row(
                                    children: [
                                      _Dot(active: true),
                                      _Dot(),
                                      _Dot(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (i) => InkWell(
                        onTap: () {
                          s.applyFilters(foods[i].category, s.distance, 0);
                          go(context, '/search');
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9F0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                [
                                  Icons.lunch_dining,
                                  Icons.local_pizza,
                                  Icons.ramen_dining,
                                  Icons.coffee,
                                ][i],
                                color: orange,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              foods[i].category,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Surface(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _quickLink(context, 'Vouchers', '/vouchers'),
                        const Divider(height: 1),
                        _quickLink(context, 'Promo', '/promo'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(
                    'Popular Now',
                    onTap: () {
                      s.clearFilters();
                      go(context, '/search');
                    },
                  ),
                  _horizontal(
                    foods.map((f) => FoodCard(f)).toList(),
                    height: 240,
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(
                    'Restaurant Nearby',
                    onTap: () => go(context, '/restaurants'),
                  ),
                  _horizontal(
                    restaurants.take(3).map((r) => RestaurantCard(r)).toList(),
                    height: 240,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: s.cartCount == 0
          ? null
          : FloatingActionButton.small(
              tooltip: 'My Cart',
              onPressed: () => go(context, '/cart'),
              backgroundColor: orange,
              child: Badge(
                label: Text('${s.cartCount}'),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _quickLink(BuildContext c, String name, String route) => InkWell(
    onTap: () => go(c, route),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          const Icon(Icons.chevron_right, size: 22),
        ],
      ),
    ),
  );
  Widget _horizontal(List<Widget> children, {required double height}) =>
      SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemBuilder: (c, i) => children[i],
          separatorBuilder: (c, i) => const SizedBox(width: 16),
          itemCount: children.length,
        ),
      );
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    width: active ? 12 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: active ? orange : pale,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantCard(this.restaurant, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 188,
    child: Surface(
      padding: const EdgeInsets.all(8),
      onTap: () => go(context, '/restaurant', arguments: restaurant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AssetImageView(
                restaurant.image,
                width: 172,
                height: 128,
                radius: 8,
              ),
              const Positioned(
                right: 4,
                top: 5,
                child: ColoredBox(color: Colors.white, child: RatingLabel()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            restaurant.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          const Text(
            '♧ Dominic Street...',
            style: TextStyle(fontSize: 10, color: muted),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: restaurant.open ? 'Open  ' : 'Closed  ',
                  style: TextStyle(
                    color: restaurant.open ? green : Colors.redAccent,
                  ),
                ),
                const TextSpan(
                  text: 'Closes 22:00',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

class RestaurantRow extends StatelessWidget {
  final Restaurant restaurant;
  final Widget? trailing;
  const RestaurantRow(this.restaurant, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Surface(
    padding: const EdgeInsets.all(12),
    onTap: () => go(context, '/restaurant', arguments: restaurant),
    child: Row(
      children: [
        AssetImageView(restaurant.image, width: 79, height: 79, radius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              const Text(
                '♧ Dominic Street Caledon...',
                style: TextStyle(color: muted, fontSize: 11),
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              const RatingLabel(),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class SearchPage extends StatefulWidget {
  final bool restaurantsOnly, filterInitially;
  const SearchPage({
    super.key,
    this.restaurantsOnly = false,
    this.filterInitially = false,
  });
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  @override
  void initState() {
    super.initState();
    if (widget.filterInitially) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _filter();
      });
    }
  }

  void _filter() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black12,
    builder: (context) => const FilterSheet(),
  );
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final result = foods
        .where(
          (f) =>
              f.name.toLowerCase().contains(query.toLowerCase()) &&
              (s.category.isEmpty || f.category == s.category) &&
              f.rating >= s.minimumRating &&
              s.matchesDistance(f.distance),
        )
        .toList();
    final places = restaurants
        .where(
          (r) =>
              r.name.toLowerCase().contains(query.toLowerCase()) &&
              4.5 >= s.minimumRating &&
              s.matchesDistance(r.distance) &&
              (s.category.isEmpty || s.category == r.category),
        )
        .toList();
    return PageFrame(
      title: widget.restaurantsOnly ? 'Restaurant Nearby' : 'Search',
      back: widget.restaurantsOnly,
      tab: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: widget.restaurantsOnly
                  ? 'Gionino Restaurant'
                  : 'Beef Burger With Cheese',
              suffixIcon: IconButton(
                tooltip: 'Filters',
                icon: const Icon(Icons.tune, color: ink),
                onPressed: _filter,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (s.category.isNotEmpty ||
              s.minimumRating > 0 ||
              s.distance.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                children: [
                  if (s.category.isNotEmpty) Chip(label: Text(s.category)),
                  if (s.distance.isNotEmpty) Chip(label: Text(s.distance)),
                  if (s.minimumRating > 0)
                    Chip(label: Text('${s.minimumRating}+ stars')),
                  ActionChip(
                    label: const Text('Clear'),
                    onPressed: s.clearFilters,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SectionTitle(widget.restaurantsOnly ? 'Discover' : 'Search Results'),
          if (widget.restaurantsOnly)
            ...places.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RestaurantRow(r),
              ),
            )
          else
            ...result.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FoodRow(f),
              ),
            ),
          if ((widget.restaurantsOnly ? places.length : result.length) == 0)
            const EmptyView(
              title: 'No results found',
              message: 'Try another search or clear your filters.',
              icon: Icons.search_off,
            ),
        ],
      ),
    );
  }
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String category = '', distance = '5KM - 10 KM';
  int rating = 0;
  bool loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      final s = AppScope.of(context);
      category = s.category;
      distance = s.distance;
      rating = s.minimumRating;
      loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Categories'),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children:
                      [
                            'Burger',
                            'Pizza',
                            'Sushi',
                            'Ramen',
                            'Donut',
                            'Chicken',
                            'Noodle',
                            'Coffee',
                          ]
                          .map(
                            (v) => _chip(
                              v,
                              category == v,
                              () => setState(
                                () => category = category == v ? '' : v,
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Distances'),
                Row(
                  children: ['< 5KM', '5KM - 10 KM', '> 10KM']
                      .map(
                        (v) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _chip(
                              v,
                              distance == v,
                              () => setState(() => distance = v),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Rating'),
                Row(
                  children: [5, 4, 3]
                      .map(
                        (v) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _chip(
                              '$v',
                              rating == v,
                              () =>
                                  setState(() => rating = rating == v ? 0 : v),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  'Apply Filters',
                  onPressed: () {
                    AppScope.of(context)
                        .applyFilters(category, distance, rating);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _chip(String text, bool selected, VoidCallback tap) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? ink : pale,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: selected ? Colors.white : muted, fontSize: 12),
      ),
    ),
  );
}

class CollectionsPage extends StatelessWidget {
  final bool wishlist;
  const CollectionsPage({super.key, this.wishlist = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        items = wishlist
            ? foods
                  .where((f) => AppScope.of(context).favorites.contains(f.id))
                  .toList()
            : foods;
    return PageFrame(
      title: wishlist ? 'Wishlist' : 'Promo',
      action: wishlist
          ? IconButton(
              tooltip: 'Search',
              onPressed: () => go(context, '/search'),
              icon: const Icon(Icons.search),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!wishlist) const SectionTitle('Today’s offers'),
          if (wishlist && items.isEmpty)
            EmptyView(
              title: 'Save your favorites',
              message: 'Tap the heart on any food to find it here.',
              button: 'Discover food',
              onPressed: () => home(context),
              icon: Icons.favorite_border,
            ),
          for (int i = 0; i < items.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: FoodCard(items[i], promo: !wishlist)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: i + 1 < items.length
                          ? FoodCard(items[i + 1], promo: !wishlist)
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          if (!wishlist)
            TextButton(
              onPressed: () {
                s.voucherClaimed = true;
                s.save();
                go(context, '/vouchers');
              },
              child: const Text('Discover more vouchers'),
            ),
        ],
      ),
    );
  }
}

class VouchersPage extends StatelessWidget {
  const VouchersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Vouchers',
      child: Column(
        children: List.generate(
          2,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AssetImageView(
                        i == 0 ? 'voucher' : 'voucher2',
                        width: double.infinity,
                        height: 106,
                        radius: 10,
                      ),
                      const Positioned(
                        left: 16,
                        top: 26,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enjoy 50% Off',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'up to Rp. 30.000',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pizza Dpulze Surabaya (maks Rp 30.000)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          i == 0 ? 'Valid for this demo' : 'Until 31 Jan, 2022',
                          style: const TextStyle(fontSize: 10, color: muted),
                        ),
                      ),
                      SizedBox(
                        width: 96,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(80, 34),
                          ),
                          onPressed: i == 1 || s.voucherClaimed
                              ? null
                              : () {
                                  s.voucherClaimed = true;
                                  s.save();
                                  toast(
                                    context,
                                    'Voucher claimed. Use DELIVER10 in your cart.',
                                  );
                                },
                          child: Text(
                            i == 1
                                ? 'Expired'
                                : s.voucherClaimed
                                ? 'Claimed'
                                : 'Claim',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RestaurantPage extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantPage({super.key, required this.restaurant});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AssetImageView(
                restaurant.image,
                height: 395,
                width: double.infinity,
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Back',
                      onPressed: () => Navigator.canPop(context)
                          ? Navigator.pop(context)
                          : home(context),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Wishlist',
                      onPressed: () => go(context, '/wishlist'),
                      icon: const Icon(Icons.favorite_border),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Text(
                      '1.25 km',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '♧ Surabaya, Indonesia',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const RatingLabel(),
                    const SizedBox(width: 12),
                    Text(
                      restaurant.open ? 'Open' : 'Closed',
                      style: const TextStyle(color: green, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Closes 22:00',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(),
                const SectionTitle('Description'),
                const Text(
                  'Ullamcorper imperdiet urna id non sed est sem. Rhoncus amet, enim purus gravida donec aliquet. Nibh sem tellus habitant.',
                  style: TextStyle(color: muted, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 20),
                const AssetImageView(
                  'address-map',
                  height: 110,
                  width: double.infinity,
                  radius: 12,
                ),
                const SizedBox(height: 24),
                const SectionTitle('Menu'),
                ...foods.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FoodRow(f),
                  ),
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
          'View Location',
          onPressed: () => go(context, '/maps', arguments: restaurant),
        ),
      ),
    ),
  );
}
