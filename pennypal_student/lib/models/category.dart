import '../utils/constants.dart';

/// A transaction category: default (categories/{key}) or custom (user_categories/{uid}/{catId}).
class Category {
  final String id;
  final String type;
  final String icon;
  final int sortOrder;
  final bool isSelectable;
  final bool isDefault;
  final String? name;
  final int? createdAt;

  Category({
    required this.id,
    required this.type,
    required this.icon,
    required this.sortOrder,
    this.isSelectable = true,
    required this.isDefault,
    this.name,
    this.createdAt,
  });

  /// Builds a default category from categories/{key}.
  factory Category.fromDefaultMap(String key, Map<dynamic, dynamic> map) {
    return Category(
      id: key,
      type: map[DbFields.type] ?? TransactionTypes.expense,
      icon: map[DbFields.icon] ?? 'category',
      sortOrder: map[DbFields.sortOrder] ?? 0,
      isSelectable: map[DbFields.isSelectable] ?? true,
      isDefault: true,
    );
  }

  /// Builds a custom category from user_categories/{uid}/{catId}.
  factory Category.fromCustomMap(String catId, Map<dynamic, dynamic> map) {
    return Category(
      id: catId,
      type: map[DbFields.type] ?? TransactionTypes.expense,
      icon: map[DbFields.icon] ?? 'category',
      sortOrder: map[DbFields.sortOrder] ?? AppDefaults.customCategorySortOrder,
      isDefault: false,
      name: map[DbFields.name],
      createdAt: map[DbFields.createdAt],
    );
  }

  /// Converts the category to a map for writing (custom and default have different fields).
  Map<String, dynamic> toMap() {
    if (isDefault) {
      return {
        DbFields.type: type,
        DbFields.icon: icon,
        DbFields.isSelectable: isSelectable,
        DbFields.sortOrder: sortOrder,
      };
    }
    return {
      DbFields.name: name,
      DbFields.type: type,
      DbFields.icon: icon,
      DbFields.sortOrder: sortOrder,
      DbFields.createdAt: createdAt,
    };
  }
}
