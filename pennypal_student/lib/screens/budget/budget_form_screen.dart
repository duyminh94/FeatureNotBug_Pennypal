import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/budget.dart';
import '../../models/transaction_record.dart';
import '../../services/budget_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/month_picker.dart';
import 'budget_cards.dart';

/// Add / edit / delete a budget. A budget is either the month's total or one expense category.
/// Rules: limit above 0 and below the app maximum, one budget per category (and one total) per month,
/// warning threshold 50–100%. When editing, the month and category are locked, only the limit changes.
class BudgetFormScreen extends StatefulWidget {
  /// Month shown when adding a budget.
  final DateTime month;

  /// All budgets, used to block a second budget for the same month and category.
  final List<Budget> budgets;

  /// All transactions, used for the "already spent" preview.
  final List<TransactionRecord> transactions;

  /// The budget being edited, null when adding.
  final Budget? initial;

  const BudgetFormScreen({
    super.key,
    required this.month,
    required this.budgets,
    required this.transactions,
    this.initial,
  });

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  // The warning slider goes from 50% to 100%.
  static const int _minThreshold = 50;
  static const int _maxThreshold = 100;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _limitController = TextEditingController();
  DateTime _month = DateTime.now();
  bool _isTotal = false;
  String? _categoryId;
  int _threshold = AppDefaults.alertThreshold;

  // Errors appear only after the first Save press, not while the student is still typing.
  bool _hasTriedToSave = false;

  bool get _isEditing {
    return widget.initial != null;
  }

  /// A new budget starts on the month being viewed; an edited one loads its saved values.
  @override
  void initState() {
    super.initState();
    _month = widget.month;

    final Budget? initial = widget.initial;
    if (initial != null) {
      _limitController.text = Formatters.groupDigits(initial.limitAmount);
      _month = BudgetCalculator.monthFromKey(initial.month);
      _isTotal = initial.isTotal;
      _categoryId = initial.categoryId;
      _threshold = initial.alertThreshold;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  /// The typed limit as a number ("1.500.000" -> 1500000), null when it is not a number.
  double? get _limitAmount {
    return Validators.parseAmount(_limitController.text);
  }

  /// The limit must be above 0 and not above the app's maximum amount.
  String? _validateLimit(String? value, AppLocalizations l10n) {
    final double? amount = Validators.parseAmount(value);
    if (!Validators.isPositiveAmount(amount)) return l10n.validationAmountPositive;
    if (!Validators.isWithinMaxAmount(amount!)) return l10n.validationAmountMax;
    return null;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Checks the form, blocks a duplicate budget, saves it and goes back with the new budget.
  /// The alert level already reached is kept when editing, so the same warning is not sent twice.
  void _save() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _hasTriedToSave = true;
    });
    if (!_formKey.currentState!.validate()) return;

    final String month = BudgetCalculator.monthKey(_month);
    // A total budget has no category.
    String? categoryId = _categoryId;
    if (_isTotal) categoryId = null;
    if (BudgetCalculator.isDuplicate(widget.budgets, month, categoryId, editing: widget.initial)) {
      _showMessage(l10n.budgetDuplicate);
      return;
    }

    final Budget budget = Budget(
      month: month,
      categoryId: categoryId,
      limitAmount: _limitAmount!,
      alertThreshold: _threshold,
      alertLevel: widget.initial?.alertLevel ?? AlertLevels.none,
      createdAt: widget.initial?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    BudgetService.save(budget);
    _showMessage(l10n.budgetSaved);
    Navigator.of(context).pop(budget);
  }

  /// Asks first, then deletes the budget. Transactions are not touched, only the limit is removed.
  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final Budget initial = widget.initial!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    String name = l10n.budgetTotal;
    if (!initial.isTotal) name = CategoryDisplay.name(l10n, initial.categoryId!);
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.budgetDeleteTitle,
      message: l10n.budgetDeleteBody(name, Formatters.monthLabel(_month, languageCode)),
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    BudgetService.delete(initial);
    _showMessage(l10n.budgetDeleted);
    Navigator.of(context).pop(FormResults.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final double? limitAmount = _limitAmount;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isEditing ? l10n.budgetEditTitle : l10n.budgetAdd,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasTriedToSave ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _FieldLabel(text: l10n.budgetMonth),
            _isEditing
                ? _LockedBox(icon: Icons.calendar_today_outlined, text: Formatters.monthLabel(_month, languageCode))
                : MonthPicker(
                    month: _month,
                    onChanged: (month) {
                      setState(() {
                        _month = month;
                      });
                    },
                  ),
            const SizedBox(height: 16),
            if (_isEditing)
              ..._buildLockedCategory(l10n)
            else
              ..._buildTypeAndCategory(l10n),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.budgetLimit),
            TextFormField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsInputFormatter()],
              // Rebuild so the "already spent" preview follows the typed limit.
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) => _validateLimit(value, l10n),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.textMuted),
                suffixText: '₫',
                hintText: '0',
                errorStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _FieldLabel(text: l10n.budgetThreshold)),
                Text('$_threshold%', style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _threshold.toDouble(),
              min: _minThreshold.toDouble(),
              max: _maxThreshold.toDouble(),
              divisions: (_maxThreshold - _minThreshold) ~/ 5,
              label: '$_threshold%',
              activeColor: AppColors.honey,
              inactiveColor: AppColors.fill,
              onChanged: (value) {
                setState(() {
                  _threshold = value.round();
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: Text('$_minThreshold%', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                  Text('$_maxThreshold%', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (limitAmount != null && limitAmount > 0) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.budgetThresholdHint(Formatters.money(limitAmount * _threshold / 100)),
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
            ],
            if (_isEditing) ...[
              const SizedBox(height: 16),
              _buildSpentPreview(l10n, languageCode, limitAmount ?? 0),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _buildBottomButtons(l10n),
        ),
      ),
    );
  }

  /// Expense categories the student can budget (income categories and savings are not listed).
  List<DropdownMenuItem<String>> _categoryItems(AppLocalizations l10n) {
    final List<DropdownMenuItem<String>> items = [];
    for (final String categoryId in CategoryKeys.selectableExpense) {
      items.add(DropdownMenuItem(
        value: categoryId,
        child: Row(
          children: [
            CategoryIcon(
              iconName: CategoryDisplay.iconName(categoryId),
              color: CategoryDisplay.color(categoryId),
              backgroundColor: CategoryDisplay.softColor(categoryId),
              size: 32,
            ),
            const SizedBox(width: 10),
            Text(CategoryDisplay.name(l10n, categoryId)),
          ],
        ),
      ));
    }
    return items;
  }

  /// Adding: choose "total" or "by category"; by category also needs the category.
  List<Widget> _buildTypeAndCategory(AppLocalizations l10n) {
    return [
      _FieldLabel(text: l10n.budgetType),
      SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: true, label: Text(l10n.budgetTypeTotal)),
          ButtonSegment(value: false, label: Text(l10n.budgetByCategory)),
        ],
        selected: {_isTotal},
        onSelectionChanged: (selected) {
          setState(() {
            _isTotal = selected.first;
          });
        },
      ),
      if (!_isTotal) ...[
        const SizedBox(height: 16),
        _FieldLabel(text: l10n.txCategory),
        DropdownButtonFormField<String>(
          value: _categoryId,
          hint: Text(l10n.validationCategory),
          validator: (value) {
            if (value == null) return l10n.validationCategory;
            return null;
          },
          onChanged: (value) {
            setState(() {
              _categoryId = value;
            });
          },
          items: _categoryItems(l10n),
        ),
      ],
    ];
  }

  /// Editing: the category is shown but locked; to change it the student deletes and adds again.
  List<Widget> _buildLockedCategory(AppLocalizations l10n) {
    final String? categoryId = widget.initial!.categoryId;

    String name = l10n.budgetTotal;
    String label = l10n.budgetType;
    if (categoryId != null) {
      name = CategoryDisplay.name(l10n, categoryId);
      label = l10n.txCategory;
    }

    return [
      _FieldLabel(text: label),
      _LockedBox(icon: Icons.sell_outlined, text: name),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
        child: Text(l10n.budgetLocked, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ),
    ];
  }

  /// Preview of how much of the new limit is already used this month.
  Widget _buildSpentPreview(AppLocalizations l10n, String languageCode, double limitAmount) {
    final Budget initial = widget.initial!;
    final double spent = BudgetCalculator.spent(widget.transactions, initial.month, categoryId: initial.categoryId);
    final int percent = BudgetCalculator.percent(spent, limitAmount);
    final BudgetStatus status = BudgetCalculator.status(spent, limitAmount, _threshold);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.budgetSpentIn(DateFormat.MMMM(languageCode).format(_month)),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${Formatters.money(spent)} · $percent%',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppProgressBar(value: percent / 100, color: BudgetColors.bar(status)),
            const SizedBox(height: 8),
            RemainingText(spent: spent, limitAmount: limitAmount, status: status),
          ],
        ),
      ),
    );
  }

  /// Save button, plus Delete when editing.
  Widget _buildBottomButtons(AppLocalizations l10n) {
    if (!_isEditing) return FilledButton(onPressed: _save, child: Text(l10n.budgetSave));

    return Row(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.expenseSoft,
            foregroundColor: AppColors.expense,
            minimumSize: const Size(54, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          tooltip: l10n.commonDelete,
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
        ),
        const SizedBox(width: 12),
        Expanded(child: FilledButton(onPressed: _save, child: Text(l10n.txSaveChanges))),
      ],
    );
  }
}

/// Bold label above a field.
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}

/// Grey read-only box for a value that cannot change while editing.
class _LockedBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LockedBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
