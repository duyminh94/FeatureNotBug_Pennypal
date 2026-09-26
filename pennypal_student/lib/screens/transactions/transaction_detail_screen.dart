import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/transaction_record.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/confirm_dialog.dart';
import 'transaction_form_screen.dart';

/// S06 Transaction details: shows every field, with delete (BR-06 confirm) and edit.
/// Pops with FormResults.deleted when the transaction was deleted.
class TransactionDetailScreen extends StatelessWidget {
  final TransactionRecord transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  bool get _isIncome => transaction.type == TransactionTypes.income;

  String _title(AppLocalizations l10n) {
    return transaction.description.isEmpty ? CategoryDisplay.name(l10n, transaction.categoryId) : transaction.description;
  }

  Future<void> _openEdit(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final Object? result = await navigator.push(
      MaterialPageRoute(builder: (context) => TransactionFormScreen(type: transaction.type, initial: transaction)),
    );
    if (result == FormResults.deleted) navigator.pop(FormResults.deleted);
    if (result == FormResults.saved) navigator.pop();
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final NavigatorState navigator = Navigator.of(context);
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.txDeleteTitle,
      message: l10n.txDeleteBody(_title(l10n), Formatters.signedMoney(transaction.amount, isIncome: _isIncome)),
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    TransactionService.delete(transaction.id);
    navigator.pop(FormResults.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String categoryId = transaction.categoryId;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.date);
    final bool isContribution = transaction.isGoalContribution;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 64,
        leading: const Padding(padding: EdgeInsets.only(left: 12), child: Center(child: CircleBackButton())),
        title: Text(l10n.detailTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          if (!isContribution)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary),
                tooltip: l10n.detailEdit,
                onPressed: () => _openEdit(context),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: CategoryIcon(
              iconName: CategoryDisplay.iconName(categoryId),
              color: CategoryDisplay.color(categoryId),
              backgroundColor: CategoryDisplay.softColor(categoryId),
              size: 72,
            ),
          ),
          const SizedBox(height: 12),
          Text(_title(l10n), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            Formatters.signedMoney(transaction.amount, isIncome: _isIncome),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: _isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _InfoRow(label: l10n.detailType, value: _isIncome ? l10n.typeIncome : l10n.typeExpense),
                  const Divider(height: 1),
                  _InfoRow(label: l10n.txCategory, value: CategoryDisplay.name(l10n, categoryId)),
                  const Divider(height: 1),
                  _InfoRow(label: l10n.txDate, value: Formatters.fullDate(date)),
                  const Divider(height: 1),
                  _InfoRow(label: l10n.txPaymentMode, value: PaymentModeDisplay.name(l10n, transaction.paymentMode)),
                ],
              ),
            ),
          ),
          if (isContribution) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.honeySoft, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined, color: AppColors.honeyText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l10n.detailContributionLocked, style: const TextStyle(color: AppColors.honeyText, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: isContribution
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.expenseSoft, foregroundColor: AppColors.expense),
                      onPressed: () => _delete(context),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.commonDelete),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _openEdit(context),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.detailEdit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
