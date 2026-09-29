import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/recurring_item.dart';
import '../../models/savings_goal.dart';
import '../../controllers/goal_service.dart';
import '../../controllers/recurring_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../utils/recurring_calculator.dart';
import '../../utils/validators.dart';
import '../../widgets/labeled_text_field.dart';
import 'cards.dart';

class GoalFormScreen extends StatefulWidget {
  final SavingsGoal? initial;

  final bool hasContributions;

  final Future<RecurringItem?> Function(String itemId) loadRecurringItem;

  const GoalFormScreen({super.key, this.initial, this.hasContributions = false, this.loadRecurringItem = RecurringService.load});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  static const int _nameMaxLength = 50;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentSavingsController = TextEditingController();
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _targetDate;

  bool _hasTriedToSave = false;

  RecurringItem? _autoItem;
  bool _isAutoContribute = false;

  bool get _isEditing {
    return widget.initial != null;
  }

  double get _contributedAmount {
    final SavingsGoal? initial = widget.initial;
    if (initial == null) return 0;
    return initial.currentAmount - initial.initialAmount;
  }

  double? get _targetAmount {
    return Validators.parseAmount(_targetController.text);
  }

  double get _currentSavings {
    return Validators.parseAmount(_currentSavingsController.text) ?? 0;
  }

  double get _monthlyContribution {
    return Validators.parseAmount(_monthlyController.text) ?? 0;
  }

  String _amountText(double? amount) {
    if (amount == null || amount == 0) return '';
    return Formatters.groupDigits(amount);
  }

  @override
  void initState() {
    super.initState();
    final SavingsGoal? initial = widget.initial;
    if (initial == null) return;

    _nameController.text = initial.name;
    _targetController.text = _amountText(initial.targetAmount);
    _currentSavingsController.text = _amountText(initial.initialAmount);
    _monthlyController.text = _amountText(initial.monthlyContribution);
    final DateTime targetDate = DateTime.fromMillisecondsSinceEpoch(initial.targetDate);
    _targetDate = targetDate;
    _dateController.text = Formatters.fullDate(targetDate);
    _loadAutoItem(initial.id);
  }

  Future<void> _loadAutoItem(String goalId) async {
    final RecurringItem? item = await widget.loadRecurringItem(RecurringCalculator.goalItemId(goalId));
    if (!mounted) return;
    setState(() {
      _autoItem = item;
      _isAutoContribute = item?.isActive ?? false;
    });
  }

  bool get _canAutoContribute {
    final bool isGoalActive = widget.initial?.isActive ?? true;
    return isGoalActive && _monthlyContribution > 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentSavingsController.dispose();
    _monthlyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, AppLocalizations l10n) {
    if (Validators.isEmpty(value)) return l10n.validationRequired;
    return null;
  }

  String? _validateTarget(String? value, AppLocalizations l10n) {
    final double? amount = Validators.parseAmount(value);
    if (!Validators.isPositiveAmount(amount)) return l10n.validationAmountPositive;
    if (!Validators.isWithinMaxAmount(amount!)) return l10n.validationAmountMax;

    final double savedAmount = _currentSavings + _contributedAmount;
    final bool isBelowSaved = _contributedAmount > 0 && amount <= savedAmount;
    if (isBelowSaved) return l10n.goalValidationTargetBelowSaved(Formatters.money(savedAmount));
    return null;
  }

  String? _validateCurrentSavings(AppLocalizations l10n) {
    final double? target = _targetAmount;
    if (target == null || target <= 0) return null;
    if (GoalCalculator.isInitialBelowTarget(_currentSavings, target)) return null;
    return l10n.goalValidationInitial;
  }

  String? _validateDate(AppLocalizations l10n) {
    final DateTime? date = _targetDate;
    if (date == null) return l10n.validationRequired;
    if (GoalCalculator.isAfterToday(date)) return null;
    return l10n.goalValidationDate;
  }

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();
    final DateTime tomorrow = DateTime(today.year, today.month, today.day + 1);

    DateTime initialDate = tomorrow;
    final DateTime? current = _targetDate;
    if (current != null && !current.isBefore(tomorrow)) initialDate = current;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime(today.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      _targetDate = picked;
      _dateController.text = Formatters.fullDate(picked);
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _hasTriedToSave = true;
    });
    if (!_formKey.currentState!.validate()) return;

    final SavingsGoal? initial = widget.initial;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final double currentAmount = _currentSavings + _contributedAmount;

    String id;
    String status = GoalStatuses.active;
    Map<String, int> milestones = {};
    int? completedAt;
    int createdAt = now;
    if (initial == null) {
      id = GoalService.newId();
    } else {
      id = initial.id;
      status = initial.status;
      milestones = initial.milestones;
      completedAt = initial.completedAt;
      createdAt = initial.createdAt ?? now;
    }

    final SavingsGoal goal = SavingsGoal(
      id: id,
      name: _nameController.text.trim(),
      targetAmount: _targetAmount!,
      initialAmount: _currentSavings,
      currentAmount: currentAmount,
      targetDate: _targetDate!.millisecondsSinceEpoch,
      monthlyContribution: _monthlyContribution,
      status: status,
      milestones: milestones,
      completedAt: completedAt,
      createdAt: createdAt,
    );
    GoalService.saveGoal(goal);
    _saveAutoContribution(goal, l10n);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.goalSaved)));
    Navigator.of(context).pop(goal);
  }

  void _saveAutoContribution(SavingsGoal goal, AppLocalizations l10n) {
    final bool wantsAuto = _isAutoContribute && _canAutoContribute;
    final String description = l10n.recurringGoalName(goal.name);
    final DateTime now = DateTime.now();

    final RecurringItem? existing = _autoItem;
    if (existing == null) {
      if (wantsAuto) RecurringService.save(RecurringCalculator.newGoalItem(goal, description, now));
      return;
    }
    final Map<String, Object?> fields = RecurringCalculator.goalItemUpdate(existing, goal, description, wantsAuto, now);
    if (fields.isNotEmpty) RecurringService.update(existing.id, fields);
  }

  Widget _buildAutoContributeSwitch(AppLocalizations l10n) {
    final String amount = Formatters.money(_monthlyContribution);
    final RecurringItem? existing = _autoItem;
    String hint = l10n.goalAutoContributeNewHint(amount, DateTime.now().day);
    if (existing != null && existing.isActive) hint = l10n.goalAutoContributeHint(amount, existing.dayOfMonth);

    return Card(
      child: SwitchListTile(
        value: _isAutoContribute,
        onChanged: (value) => setState(() => _isAutoContribute = value),
        secondary: const Icon(Icons.event_repeat, color: AppColors.primary),
        title: Text(l10n.goalAutoContribute, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isCurrentSavingsLocked = widget.hasContributions;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isEditing ? l10n.goalEditTitle : l10n.goalAdd,
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
            LabeledTextField(
              label: l10n.goalName,
              icon: Icons.flag_outlined,
              controller: _nameController,
              hintText: l10n.goalNameHint,
              maxLength: _nameMaxLength,
              validator: (value) => _validateName(value, l10n),
            ),
            const SizedBox(height: 8),
            _AmountField(
              label: l10n.goalTargetAmount,
              icon: Icons.outlined_flag,
              controller: _targetController,
              validator: (value) => _validateTarget(value, l10n),
              onChanged: () {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _AmountField(
              label: l10n.goalCurrentSavings,
              icon: Icons.savings_outlined,
              controller: _currentSavingsController,
              helperText: isCurrentSavingsLocked ? l10n.goalCurrentSavingsLocked : l10n.goalCurrentSavingsHelp,
              isReadOnly: isCurrentSavingsLocked,
              validator: (_) => _validateCurrentSavings(l10n),
              onChanged: () {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.goalTargetDate),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              validator: (_) => _validateDate(l10n),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 20),
                hintText: 'dd/mm/yyyy',
                errorStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            _AmountField(
              label: l10n.goalMonthlyContribution,
              icon: Icons.event_repeat_outlined,
              controller: _monthlyController,
              helperText: l10n.goalMonthlyContributionHelp,
              onChanged: () {
                setState(() {});
              },
            ),
            if (_canAutoContribute) ...[
              const SizedBox(height: 12),
              _buildAutoContributeSwitch(l10n),
            ],
            const SizedBox(height: 16),
            _buildEstimate(l10n),
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
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.textPrimary),
            onPressed: _save,
            child: Text(_isEditing ? l10n.txSaveChanges : l10n.goalAdd),
          ),
        ),
      ),
    );
  }

  Widget _buildEstimate(AppLocalizations l10n) {
    final double? target = _targetAmount;
    final double current = _currentSavings + _contributedAmount;
    if (target == null || target <= 0 || current >= target) return const SizedBox.shrink();

    final double remaining = GoalCalculator.remaining(target, current);
    final int? months = GoalCalculator.monthsLeft(remaining, _monthlyContribution);
    final DateTime? estimated = GoalCalculator.estimatedDate(months);
    final DateTime? targetDate = _targetDate;
    final String remainingText = months == null
        ? l10n.dashBudgetLeft(Formatters.money(remaining))
        : l10n.goalRemainingMonths(Formatters.money(remaining), months);
    final String finishText = estimated == null
        ? l10n.goalNotEstimated
        : l10n.goalFinishAround(Formatters.monthYear(estimated.millisecondsSinceEpoch));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: GoalProgressRing(
              progress: GoalCalculator.progress(target, current),
              size: 72,
              color: AppColors.mint,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.goalEstimateTitle, style: const TextStyle(fontSize: 14, color: AppColors.textOnDark)),
                Text(
                  remainingText,
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(finishText, style: const TextStyle(fontSize: 14, color: AppColors.textOnDark)),
                if (targetDate != null) ...[
                  const SizedBox(height: 8),
                  GoalPaceBadge(pace: GoalCalculator.pace(estimated, targetDate)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _AmountField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? helperText;
  final bool isReadOnly;
  final String? Function(String?)? validator;
  final VoidCallback onChanged;

  const _AmountField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.onChanged,
    this.helperText,
    this.isReadOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: label),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsInputFormatter()],
          validator: validator,
          onChanged: (_) => onChanged(),
          style: TextStyle(fontSize: 16, color: isReadOnly ? AppColors.textMuted : AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 22),
            suffixIcon: isReadOnly ? const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20) : null,
            prefixText: Formatters.isUsd ? '\$ ' : null,
            suffixText: Formatters.isUsd ? null : '₫',
            hintText: '0',
            helperText: helperText,
            helperMaxLines: 2,
            errorMaxLines: 2,
            errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
