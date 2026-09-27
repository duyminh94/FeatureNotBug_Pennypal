import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction_record.dart';
import '../../utils/app_theme.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/category_display.dart';
import '../../utils/category_manager.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/confirm_dialog.dart';
import 'category_form_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Category>? customCategories;
  final List<TransactionRecord>? transactions;
  final List<Budget>? budgets;

  const CategoriesScreen({super.key, this.customCategories, this.transactions, this.budgets});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final List<Category> _custom = [...(widget.customCategories ?? const [])];
  late List<TransactionRecord> _transactions = widget.transactions ?? const [];
  late List<Budget> _budgets = widget.budgets ?? const [];
  String _type = TransactionTypes.expense;

  String _nameOf(AppLocalizations l10n, String categoryId) {
    for (final Category category in _custom) {
      if (category.id == categoryId) return category.name ?? '';
    }
    return CategoryDisplay.name(l10n, categoryId);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openForm({Category? category}) async {
    final l10n = AppLocalizations.of(context)!;
    final Category? saved = await showCategoryFormSheet(
      context,
      type: _type,
      customCategories: _custom,
      initial: category,
      canChangeType: category == null || CategoryManager.canChangeType(category.id, _transactions),
    );
    if (saved == null || !mounted) return;

    setState(() {
      final int index = _custom.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _custom[index] = saved;
      } else {
        _custom.add(saved);
      }
      _type = saved.type;
    });
    _showMessage(l10n.categorySaved);
  }

  Future<void> _delete(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final int transactionCount = CategoryManager.transactionCount(category.id, _transactions);
    final int budgetCount = CategoryManager.budgetCount(category.id, _budgets);

    if (transactionCount == 0 && budgetCount == 0) {
      final bool confirmed = await showConfirmDialog(
        context,
        title: l10n.categoryDeleteTitle(category.name ?? ''),
        message: l10n.categoryDeleteBody,
        confirmLabel: l10n.commonDelete,
        isDestructive: true,
        icon: Icons.delete_outline,
      );
      if (!confirmed || !mounted) return;
      setState(() => _custom.remove(category));
      _showMessage(l10n.categoryDeleted);
      return;
    }

    final String? targetId = await _pickMergeTarget(l10n, category, transactionCount, budgetCount);
    if (targetId == null || !mounted) return;

    final MergeResult result = CategoryManager.merge(
      fromId: category.id,
      toId: targetId,
      transactions: _transactions,
      budgets: _budgets,
    );
    setState(() {
      _transactions = result.transactions;
      _budgets = result.budgets;
      _custom.remove(category);
    });

    final String targetName = _nameOf(l10n, targetId);
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String keptMonths = result.keptTargetMonths
        .map((month) => Formatters.monthLabel(BudgetCalculator.monthFromKey(month), languageCode))
        .join(', ');
    final String message = l10n.categoryMerged(result.movedTransactions, result.movedBudgets, targetName);
    _showMessage(keptMonths.isEmpty ? message : '$message ${l10n.categoryKeptBudgets(targetName, keptMonths)}');
  }

  Future<String?> _pickMergeTarget(AppLocalizations l10n, Category category, int transactionCount, int budgetCount) {
    final List<String> targets = CategoryManager.mergeTargets(category, _custom);
    final String fallback = category.type == TransactionTypes.income ? CategoryKeys.otherIncome : CategoryKeys.miscellaneous;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        String selected = fallback;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.8),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Row(
                      children: [
                        _Avatar(category: category, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.categoryDeleteTitle(category.name ?? ''),
                                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                l10n.categoryMoveTo(transactionCount, budgetCount),
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...targets.map((targetId) {
                      final bool isSelected = targetId == selected;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setSheetState(() => selected = targetId),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppColors.textPrimary : AppColors.border,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                _TargetIcon(categoryId: targetId, custom: _custom),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_nameOf(l10n, targetId), style: const TextStyle(fontSize: 16))),
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text(l10n.categoryMoveAndDelete),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Category> mine = _custom.where((category) => category.type == _type).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.menuCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: Colors.white),
            tooltip: l10n.categoryAdd,
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: TransactionTypes.expense, label: Text(l10n.categoryExpenseTab)),
              ButtonSegment(value: TransactionTypes.income, label: Text(l10n.categoryIncomeTab)),
            ],
            selected: {_type},
            onSelectionChanged: (selected) => setState(() => _type = selected.first),
          ),
          const SizedBox(height: 20),
          _SectionTitle(text: l10n.categoryMine),
          if (mine.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.categoryNoCustom, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            _Group(
              children: mine.map((category) {
                final int transactionCount = CategoryManager.transactionCount(category.id, _transactions);
                final int budgetCount = CategoryManager.budgetCount(category.id, _budgets);
                final bool isUsed = transactionCount > 0 || budgetCount > 0;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _Avatar(category: category),
                  title: Text(category.name ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  subtitle: Text(isUsed ? l10n.categoryUsage(transactionCount, budgetCount) : l10n.categoryNotUsed),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.fill, foregroundColor: AppColors.textPrimary),
                        tooltip: l10n.commonEdit,
                        onPressed: () => _openForm(category: category),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.expenseSoft, foregroundColor: AppColors.expense),
                        tooltip: l10n.commonDelete,
                        onPressed: () => _delete(category),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          _SectionTitle(text: l10n.categoryDefault),
          _Group(
            children: CategoryManager.defaultKeys(_type).map((key) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CategoryIcon(
                  iconName: CategoryDisplay.iconName(key),
                  color: CategoryDisplay.color(key),
                  backgroundColor: CategoryDisplay.softColor(key),
                  size: 44,
                ),
                title: Text(CategoryDisplay.name(l10n, key), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.lock_outline, color: AppColors.textMuted),
              );
            }).toList(),
          ),
          if (_type == TransactionTypes.expense) ...[
            const SizedBox(height: 12),
            Text(l10n.categorySavingsNote, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700)),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int index = 0; index < children.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: AppColors.border),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Category category;
  final double size;

  const _Avatar({required this.category, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return CategoryIcon(iconName: category.icon, color: AppColors.expense, backgroundColor: AppColors.expenseSoft, size: size);
  }
}

class _TargetIcon extends StatelessWidget {
  final String categoryId;
  final List<Category> custom;

  const _TargetIcon({required this.categoryId, required this.custom});

  @override
  Widget build(BuildContext context) {
    for (final Category category in custom) {
      if (category.id == categoryId) return _Avatar(category: category, size: 40);
    }
    return CategoryIcon(
      iconName: CategoryDisplay.iconName(categoryId),
      color: CategoryDisplay.color(categoryId),
      backgroundColor: CategoryDisplay.softColor(categoryId),
      size: 40,
    );
  }
}
