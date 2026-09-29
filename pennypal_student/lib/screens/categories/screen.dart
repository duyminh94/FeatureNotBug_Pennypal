import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction_record.dart';
import '../../controllers/budget_service.dart';
import '../../controllers/category_service.dart';
import '../../controllers/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/category_manager.dart';
import '../../utils/constants.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/error_state.dart';
import 'form_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  final String uid;
  final Stream<List<Category>> Function(String uid) watchCategories;
  final Stream<List<TransactionRecord>> Function(String uid) watchTransactions;
  final Stream<List<Budget>> Function(String uid) watchBudgets;
  final void Function(Category category) saveCategory;
  final void Function(Category category) deleteCategory;

  const CategoriesScreen({
    super.key,
    required this.uid,
    this.watchCategories = CategoryService.watch,
    this.watchTransactions = TransactionService.watch,
    this.watchBudgets = BudgetService.watch,
    this.saveCategory = CategoryService.save,
    this.deleteCategory = CategoryService.delete,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _custom = [];
  List<TransactionRecord> _transactions = [];
  List<Budget> _budgets = [];
  bool _hasCategories = false;
  bool _hasTransactions = false;
  bool _hasBudgets = false;
  bool _hasError = false;
  StreamSubscription<List<Category>>? _categorySubscription;
  StreamSubscription<List<TransactionRecord>>? _transactionSubscription;
  StreamSubscription<List<Budget>>? _budgetSubscription;
  String _type = TransactionTypes.expense;

  @override
  void initState() {
    super.initState();
    _listenData();
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    super.dispose();
  }

  void _listenData() {
    _categorySubscription?.cancel();
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    try {
      _categorySubscription = widget.watchCategories(widget.uid).listen(
        (categories) => setState(() {
          _custom = categories;
          _hasCategories = true;
        }),
        onError: _onDataError,
      );
      _transactionSubscription = widget.watchTransactions(widget.uid).listen(
        (transactions) => setState(() {
          _transactions = transactions;
          _hasTransactions = true;
        }),
        onError: _onDataError,
      );
      _budgetSubscription = widget.watchBudgets(widget.uid).listen(
        (budgets) => setState(() {
          _budgets = budgets;
          _hasBudgets = true;
        }),
        onError: _onDataError,
      );
    } catch (e) {
      _onDataError(e);
    }
  }

  void _onDataError(Object error) {
    debugPrint('CategoriesScreen data failed: $error');
    if (!mounted) return;
    setState(() => _hasError = true);
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _hasCategories = false;
      _hasTransactions = false;
      _hasBudgets = false;
    });
    _listenData();
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
      canChangeType: category == null || CategoryManager.canChangeType(category.id, _transactions, _budgets),
    );
    if (saved == null || !mounted) return;

    widget.saveCategory(saved);
    setState(() => _type = saved.type);
    _showMessage(l10n.categorySaved);
  }

  Future<void> _delete(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final int transactionCount = CategoryManager.transactionCount(category.id, _transactions);
    final int budgetCount = CategoryManager.budgetCount(category.id, _budgets);

    if (transactionCount > 0 || budgetCount > 0) {
      _showMessage(l10n.categoryInUse(transactionCount, budgetCount));
      return;
    }

    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.categoryDeleteTitle(category.name ?? ''),
      message: l10n.categoryDeleteBody,
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    widget.deleteCategory(category);
    _showMessage(l10n.categoryDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final AppBar appBar = AppBar(
      centerTitle: true,
      title: Text(l10n.menuCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      actions: [
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: Colors.white),
          tooltip: l10n.categoryAdd,
          onPressed: _hasError || !_hasCategories ? null : () => _openForm(),
          icon: const Icon(Icons.add),
        ),
        const SizedBox(width: 12),
      ],
    );

    if (_hasError) return Scaffold(appBar: appBar, body: ErrorState(onRetry: _retry));
    if (!_hasCategories || !_hasTransactions || !_hasBudgets) {
      return Scaffold(appBar: appBar, body: const Center(child: CircularProgressIndicator()));
    }

    final List<Category> mine = _custom.where((category) => category.type == _type).toList();

    return Scaffold(
      appBar: appBar,
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

  const _Avatar({required this.category});

  @override
  Widget build(BuildContext context) {
    final String colorKey = category.color ?? '';
    return CategoryIcon(
      iconName: category.icon,
      color: CategoryDisplay.customColor(colorKey),
      backgroundColor: CategoryDisplay.customSoftColor(colorKey),
      size: 44,
    );
  }
}
