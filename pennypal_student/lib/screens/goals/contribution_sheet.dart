import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/savings_goal.dart';
import '../../models/transaction_record.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../utils/validators.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_text_field.dart';

/// Opens the contribution sheet from the bottom of the screen.
/// Returns the new / edited contribution, FormResults.deleted, or null when closed.
Future<Object?> showContributionSheet(
  BuildContext context, {
  required SavingsGoal goal,
  required double balance,
  TransactionRecord? contribution,
}) {
  return showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => ContributionSheet(goal: goal, balance: balance, contribution: contribution),
  );
}

/// Add or edit money put into a goal. A contribution is saved as a "savings" expense linked to the goal,
/// so the balance goes down but budgets do not count it as spending.
/// Rule: more than 0 and not more than what the goal still needs. Going above the balance only warns.
class ContributionSheet extends StatefulWidget {
  final SavingsGoal goal;

  /// Current balance, used for the "more than your balance" warning.
  final double balance;

  /// The contribution being edited, null when adding.
  final TransactionRecord? contribution;

  const ContributionSheet({super.key, required this.goal, required this.balance, this.contribution});

  @override
  State<ContributionSheet> createState() => _ContributionSheetState();
}

class _ContributionSheetState extends State<ContributionSheet> {
  // Quick buttons that add 200k / 500k / 1M to the typed amount.
  static const List<double> _quickAmounts = [200000, 500000, 1000000];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _date = DateTime.now();

  bool get _isEditing {
    return widget.contribution != null;
  }

  /// Amount before editing (0 when adding); it is given back to the goal before checking the new amount.
  double get _oldAmount {
    return widget.contribution?.amount ?? 0;
  }

  /// The typed amount as a number, 0 when empty or not a number.
  double get _amount {
    return Validators.parseAmount(_amountController.text) ?? 0;
  }

  /// A new contribution starts today; an edited one loads its saved values.
  @override
  void initState() {
    super.initState();
    final TransactionRecord? contribution = widget.contribution;
    if (contribution != null) {
      _amountController.text = Formatters.groupDigits(contribution.amount);
      _noteController.text = contribution.description;
      _date = DateTime.fromMillisecondsSinceEpoch(contribution.date);
    }
    _dateController.text = Formatters.fullDate(_date);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Amount must be above 0 and not above what the goal still needs.
  String? _validateAmount(AppLocalizations l10n) {
    if (_amount <= 0) return l10n.validationAmountPositive;

    final bool isAllowed = GoalCalculator.isContributionAllowed(widget.goal, _amount, oldAmount: _oldAmount);
    if (isAllowed) return null;
    final double maxAmount = widget.goal.remainingAmount + _oldAmount;
    return l10n.goalContributionTooMuch(Formatters.money(maxAmount));
  }

  /// Adds a quick amount to what is already typed.
  void _addQuickAmount(double value) {
    setState(() {
      _amountController.text = Formatters.groupDigits(_amount + value);
    });
  }

  /// Date picker limited to the last 5 years up to today; a contribution cannot be in the future.
  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = Formatters.fullDate(picked);
    });
  }

  /// Builds the contribution and returns it to the goal screen, which saves it together with the goal.
  /// When editing, the id and creation time stay the same and updatedAt is set.
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final TransactionRecord? old = widget.contribution;
    final int now = DateTime.now().millisecondsSinceEpoch;

    String id;
    int createdAt;
    int? updatedAt;
    if (old == null) {
      id = TransactionService.newId();
      createdAt = now;
      updatedAt = null;
    } else {
      id = old.id;
      createdAt = old.createdAt ?? now;
      updatedAt = now;
    }

    final TransactionRecord contribution = TransactionRecord(
      id: id,
      type: TransactionTypes.expense,
      amount: _amount,
      categoryId: CategoryKeys.savings,
      description: _noteController.text.trim(),
      date: _date.millisecondsSinceEpoch,
      paymentMode: old?.paymentMode,
      goalId: widget.goal.id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    Navigator.of(context).pop(contribution);
  }

  /// Asks first, then tells the goal screen to delete this contribution.
  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.goalDeleteContributionTitle,
      message: l10n.goalDeleteContributionBody(Formatters.money(_oldAmount)),
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (confirmed && mounted) Navigator.of(context).pop(FormResults.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Only the extra money counts against the balance when editing.
    final bool isOverBalance = _amount - _oldAmount > widget.balance;

    String saveLabel = l10n.goalContribute;
    if (_isEditing) {
      saveLabel = l10n.txSaveChanges;
    } else if (_amount > 0) {
      saveLabel = l10n.goalContributeButton(Formatters.money(_amount));
    }

    // Warn (but still allow) when the contribution is more than the balance.
    IconData noticeIcon = Icons.info_outline;
    String noticeText = l10n.goalContributionInfo;
    if (isOverBalance) {
      noticeIcon = Icons.warning_amber_rounded;
      noticeText = l10n.goalContributionOverBalance(Formatters.money(widget.balance));
    }

    final List<Widget> quickChips = [];
    for (final double value in _quickAmounts) {
      quickChips.add(ActionChip(
        label: Text('+${Formatters.groupDigits(value)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _addQuickAmount(value),
      ));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Text(
                _isEditing ? l10n.goalEditContribution : l10n.goalContributeTo(widget.goal.name),
                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(22)),
                child: Column(
                  children: [
                    Text(
                      l10n.goalContributionAmount,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsInputFormatter()],
                      textAlign: TextAlign.center,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (_) => _validateAmount(l10n),
                      // Rebuild so the button text and the balance warning follow the typed amount.
                      onChanged: (_) {
                        setState(() {});
                      },
                      style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 34, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixText: Formatters.isUsd ? '\$ ' : null,
                        suffixText: Formatters.isUsd ? null : '₫',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickChips,
              ),
              const SizedBox(height: 12),
              _Notice(icon: noticeIcon, text: noticeText),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  l10n.txDate,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                validator: (_) {
                  if (Validators.isNotFutureDate(_date)) return null;
                  return l10n.validationDateFuture;
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: l10n.goalNote,
                icon: Icons.edit_outlined,
                controller: _noteController,
                hintText: l10n.goalNoteHint,
                maxLength: AppDefaults.descriptionMaxLength,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_isEditing) ...[
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
                  ],
                  Expanded(child: FilledButton(onPressed: _save, child: Text(saveLabel))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Honey box with an info or warning message.
class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.honeySoft, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.honeyText, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
