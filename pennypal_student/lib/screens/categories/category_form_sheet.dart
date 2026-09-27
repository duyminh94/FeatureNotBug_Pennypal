import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/category_manager.dart';
import '../../utils/constants.dart';
import '../../widgets/category_icon.dart';

Future<Category?> showCategoryFormSheet(
  BuildContext context, {
  required String type,
  required List<Category> customCategories,
  Category? initial,
  bool canChangeType = true,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => CategoryFormSheet(
      type: type,
      customCategories: customCategories,
      initial: initial,
      canChangeType: canChangeType,
    ),
  );
}

class CategoryFormSheet extends StatefulWidget {
  final String type;
  final List<Category> customCategories;
  final Category? initial;
  final bool canChangeType;

  const CategoryFormSheet({
    super.key,
    required this.type,
    required this.customCategories,
    this.initial,
    this.canChangeType = true,
  });

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.initial?.name ?? '');
  late String _type = widget.initial?.type ?? widget.type;
  late String _icon = widget.initial?.icon ?? CustomCategoryIcons.values.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> _defaultNames() {
    final AppLocalizations english = lookupAppLocalizations(const Locale('en'));
    final AppLocalizations vietnamese = lookupAppLocalizations(const Locale('vi'));
    final List<String> keys = [
      ...CategoryManager.defaultKeys(_type),
      if (_type == TransactionTypes.expense) CategoryKeys.savings,
    ];
    return [
      for (final String key in keys) ...[key, CategoryDisplay.name(english, key), CategoryDisplay.name(vietnamese, key)],
    ];
  }

  String? _validateName(String? value, AppLocalizations l10n) {
    final String name = value ?? '';
    if (!CategoryManager.isValidNameLength(name)) return l10n.categoryNameLength;
    final bool isDuplicate = CategoryManager.isDuplicateName(
      name: name,
      type: _type,
      defaultNames: _defaultNames(),
      customCategories: widget.customCategories,
      editingId: widget.initial?.id,
    );
    return isDuplicate ? l10n.categoryNameExists : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final Category? initial = widget.initial;
    final int now = DateTime.now().millisecondsSinceEpoch;
    Navigator.of(context).pop(Category(
      id: initial?.id ?? CategoryService.newId(),
      type: _type,
      icon: _icon,
      sortOrder: initial?.sortOrder ?? AppDefaults.customCategorySortOrder,
      isDefault: false,
      name: _nameController.text.trim(),
      createdAt: initial?.createdAt ?? now,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.initial == null ? l10n.categoryAdd : l10n.categoryEdit,
                      style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                  CategoryIcon(iconName: _icon, color: AppColors.expense, backgroundColor: AppColors.expenseSoft, size: 52),
                ],
              ),
              const SizedBox(height: 16),
              _Label(text: l10n.categoryName),
              TextFormField(
                controller: _nameController,
                maxLength: CategoryManager.nameMax,
                validator: (value) => _validateName(value, l10n),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.sell_outlined, color: AppColors.textMuted),
                  helperText: l10n.categoryNameHelp,
                  helperMaxLines: 2,
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              _Label(text: l10n.categoryType),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: TransactionTypes.expense, label: Text(l10n.categoryExpenseTab)),
                  ButtonSegment(value: TransactionTypes.income, label: Text(l10n.categoryIncomeTab)),
                ],
                selected: {_type},
                onSelectionChanged: widget.canChangeType ? (selected) => setState(() => _type = selected.first) : null,
              ),
              if (!widget.canChangeType)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: Text(l10n.categoryTypeLocked, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ),
              const SizedBox(height: 16),
              _Label(text: l10n.categoryIcon),
              GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: CustomCategoryIcons.values.map((iconName) {
                  final bool isSelected = iconName == _icon;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: iconName,
                    child: InkWell(
                      onTap: () => setState(() => _icon = iconName),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.expenseSoft : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.textPrimary : AppColors.border,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Icon(categoryIconData(iconName), color: isSelected ? AppColors.expense : AppColors.textSecondary),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: Text(l10n.categorySave)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}
