import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/catalog.dart';
import 'theme.dart';

void go(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void home(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );

class AssetImageView extends StatelessWidget {
  final String name;
  final double? width, height;
  final BoxFit fit;
  final double radius;
  const AssetImageView(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
    ),
  );
}

class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom, action;
  final bool back, scroll;
  final int? tab;
  final EdgeInsets padding;
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.action,
    this.back = true,
    this.scroll = true,
    this.tab,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: back
          ? IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.canPop(context)
                  ? Navigator.pop(context)
                  : home(context),
            )
          : null,
      actions: action == null ? null : [action!, const SizedBox(width: 12)],
    ),
    body: SafeArea(
      top: false,
      child: scroll
          ? SingleChildScrollView(padding: padding, child: child)
          : Padding(padding: padding, child: child),
    ),
    bottomNavigationBar: tab != null
        ? BottomTabs(index: tab!)
        : bottom == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: bottom,
            ),
          ),
  );
}

class BottomTabs extends StatelessWidget {
  final int index;
  const BottomTabs({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    const routes = ['/home', '/search', '/orders', '/profile'];
    const labels = ['Home', 'Search', 'Orders', 'Profile'];
    const icons = [
      Icons.home_outlined,
      Icons.search,
      Icons.chat_bubble_outline,
      Icons.person_outline,
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: IconButton(
                  tooltip: labels[i],
                  onPressed: () {
                    if (index != i) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        routes[i],
                        (r) => false,
                      );
                    }
                  },
                  icon: Icon(
                    icons[i],
                    color: i == index ? orange : muted,
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton(this.label, {super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}

class Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: line),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const SectionTitle(this.title, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text('See All', style: TextStyle(fontSize: 11)),
          ),
      ],
    ),
  );
}

class RatingLabel extends StatelessWidget {
  final double rating;
  const RatingLabel({super.key, this.rating = 4.5});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star_rounded, color: orange, size: 20),
      const SizedBox(width: 4),
      Text('$rating', style: const TextStyle(fontSize: 12)),
    ],
  );
}

class FoodThumb extends StatelessWidget {
  final Food food;
  final double size;
  const FoodThumb(this.food, {super.key, this.size = 71});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * .12),
    decoration: BoxDecoration(
      color: const Color(0xFFECEBEF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: AssetImageView(food.image, fit: BoxFit.contain),
  );
}

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback minus, plus;
  const QuantityControl({
    super.key,
    required this.quantity,
    required this.minus,
    required this.plus,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Decrease quantity',
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
        icon: const Icon(Icons.remove_circle_outline, size: 20, color: muted),
        onPressed: minus,
      ),
      Text('$quantity', style: const TextStyle(fontSize: 13)),
      IconButton(
        tooltip: 'Increase quantity',
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
        icon: const Icon(Icons.add_circle_outline, size: 20, color: muted),
        onPressed: plus,
      ),
    ],
  );
}

class FoodCard extends StatelessWidget {
  final Food food;
  final bool promo;
  const FoodCard(this.food, {super.key, this.promo = false});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SizedBox(
      width: 188,
      child: Surface(
        padding: const EdgeInsets.all(8),
        onTap: () => go(context, '/food', arguments: food),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 128,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEBEF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AssetImageView(food.image, fit: BoxFit.contain),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    color: Colors.white,
                    child: RatingLabel(rating: food.rating),
                  ),
                ),
                if (promo)
                  Positioned(
                    top: 6,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Promo 40%',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              food.shortName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 12, color: muted),
                SizedBox(width: 3),
                Expanded(
                  child: Text(
                    'Dominic Street...',
                    style: TextStyle(fontSize: 10, color: muted),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  money(food.price),
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Favorite ${food.shortName}',
                    onPressed: () => state.toggleFavorite(food),
                    icon: Icon(
                      state.favorites.contains(food.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: orange,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodRow extends StatelessWidget {
  final Food food;
  final Widget? trailing;
  final String? subtitle;
  const FoodRow(this.food, {super.key, this.trailing, this.subtitle});
  @override
  Widget build(BuildContext context) => Surface(
    padding: const EdgeInsets.all(12),
    onTap: () => go(context, '/food', arguments: food),
    child: Row(
      children: [
        FoodThumb(food),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.shortName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle ?? 'Gionino Restaurant',
                style: const TextStyle(fontSize: 11, color: muted),
              ),
              const SizedBox(height: 5),
              Text(
                money(food.price),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class LabeledField extends StatelessWidget {
  final String label, hint;
  final TextEditingController? controller;
  final bool obscure;
  final int lines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  const LabeledField(
    this.label, {
    super.key,
    this.hint = '',
    this.controller,
    this.obscure = false,
    this.lines = 1,
    this.keyboardType,
    this.validator,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          maxLines: lines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            border: lines > 1
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: line),
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}

class EmptyView extends StatelessWidget {
  final String title, message;
  final String? button;
  final VoidCallback? onPressed;
  final IconData icon;
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.button,
    this.onPressed,
    this.icon = Icons.shopping_bag_outlined,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 70),
    child: Column(
      children: [
        Icon(icon, size: 72, color: orange),
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
        if (button != null) ...[
          const SizedBox(height: 32),
          PrimaryButton(button!, onPressed: onPressed),
        ],
      ],
    ),
  );
}
