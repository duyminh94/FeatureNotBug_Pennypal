import 'package:flutter/material.dart';

/// Material icons for the 13 default categories and the 12 custom-category choices.
const Map<String, IconData> _iconsByName = {
  'restaurant': Icons.restaurant,
  'directions_bus': Icons.directions_bus,
  'school': Icons.school,
  'shopping_bag': Icons.shopping_bag,
  'movie': Icons.movie,
  'receipt_long': Icons.receipt_long,
  'savings': Icons.savings,
  'more_horiz': Icons.more_horiz,
  'family_restroom': Icons.family_restroom,
  'emoji_events': Icons.emoji_events,
  'work': Icons.work,
  'badge': Icons.badge,
  'attach_money': Icons.attach_money,
  'fitness_center': Icons.fitness_center,
  'pets': Icons.pets,
  'local_cafe': Icons.local_cafe,
  'sports_esports': Icons.sports_esports,
  'flight': Icons.flight,
  'card_giftcard': Icons.card_giftcard,
  'health_and_safety': Icons.health_and_safety,
  'phone_android': Icons.phone_android,
  'home': Icons.home,
  'child_care': Icons.child_care,
  'volunteer_activism': Icons.volunteer_activism,
  'category': Icons.category,
};

/// Converts an icon name stored in the database to IconData (unknown names show a generic icon).
IconData categoryIconData(String iconName) {
  return _iconsByName[iconName] ?? Icons.category;
}

/// Rounded square icon used in category lists and transaction rows.
class CategoryIcon extends StatelessWidget {
  final String iconName;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.color,
    this.backgroundColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? mainColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(categoryIconData(iconName), color: mainColor, size: size * 0.55),
    );
  }
}
