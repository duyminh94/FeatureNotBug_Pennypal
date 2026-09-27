import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/recurring_item.dart';
import '../../services/recurring_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/recurring_calculator.dart';
import '../../utils/validators.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

/// Fixed monthly incomes and expenses: change the amount, stop / turn back on, delete.
class RecurringScreen extends StatefulWidget {
  final String uid;
  final Stream<List<RecurringItem>> Function(String uid) watchItems;
  final void Function(String itemId, Map<String, Object?> fields) updateItem;
  final void Function(String itemId) deleteItem;

  const RecurringScreen({
    super.key,
    required this.uid,
    this.watchItems = RecurringService.watch,
    this.updateItem = RecurringService.update,
    this.deleteItem = RecurringService.delete,
  });

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  List<RecurringItem> _items = [];
  bool _hasData = false;
  bool _hasError = false;
  StreamSubscription<List<RecurringItem>>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenItems();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenItems() {
    _subscription?.cancel();
    try {
      _subscription = widget.watchItems(widget.uid).listen(
            (items) => setState(() {
              _items = items;
              _hasData = true;
            }),
            onError: _onDataError,
          );
    } catch (e) {
      _onDataError(e);
    }
  }

  void _onDataError(Object error) {
    debugPrint('RecurringScreen data failed: $error');
    if (!mounted) return;
    setState(() => _hasError = true);
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _hasData = false;
    });
    _listenItems();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _setActive(RecurringItem item, bool isActive) {
    final l10n = AppLocalizations.of(context)!;
    if (isActive) {
      widget.updateItem(item.id, {
        DbFields.isActive: true,
        DbFields.lastCreatedMonth: RecurringCalculator.monthKeyOnResume(item, DateTime.now()),
      });
      _showMessage(l10n.recurringResumedMessage);
    } else {
      widget.updateItem(item.id, {DbFields.isActive: false});
      _showMessage(l10n.recurringStoppedMessage);
    }
  }

  Future<void> _editAmount(RecurringItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final double? amount = await showDialog<double>(
      context: context,
      builder: (context) => _AmountDialog(initialAmount: item.amount),
    );
    if (amount == null || !mounted) return;

    widget.updateItem(item.id, {DbFields.amount: amount});
    _showMessage(l10n.recurringAmountSaved);
  }

  Future<void> _delete(RecurringItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.recurringDeleteTitle,
      message: l10n.recurringDeleteBody,
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    widget.deleteItem(item.id);
    _showMessage(l10n.recurringDeleted);
  }

  String _itemName(AppLocalizations l10n, RecurringItem item) {
    if (item.description.isNotEmpty) return item.description;
    return CategoryDisplay.name(l10n, item.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final AppBar appBar = AppBar(
      centerTitle: true,
      title: Text(l10n.menuRecurring, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );

    if (_hasError) return Scaffold(appBar: appBar, body: ErrorState(onRetry: _retry));
    if (!_hasData) return Scaffold(appBar: appBar, body: const Center(child: CircularProgressIndicator()));
    if (_items.isEmpty) {
      return Scaffold(appBar: appBar, body: EmptyState(icon: Icons.event_repeat, message: l10n.recurringEmpty));
    }

    return Scaffold(
      appBar: appBar,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(l10n.recurringNote, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          for (final RecurringItem item in _items) _buildItemCard(l10n, item),
        ],
      ),
    );
  }

  Widget _buildItemCard(AppLocalizations l10n, RecurringItem item) {
    String details = '${Formatters.signedMoney(item.amount, isIncome: item.isIncome)} · ${l10n.recurringDay(item.dayOfMonth)}';
    if (!item.isActive) details = '$details · ${l10n.recurringStopped}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(
                  iconName: CategoryDisplay.iconName(item.categoryId),
                  color: CategoryDisplay.color(item.categoryId),
                  backgroundColor: CategoryDisplay.softColor(item.categoryId),
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_itemName(l10n, item), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(details, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Switch(value: item.isActive, onChanged: (value) => _setActive(item, value)),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.end,
              children: [
                // A goal's monthly amount is changed in the goal form, so both places show the same number.
                if (!item.isGoalContribution)
                  TextButton.icon(
                    onPressed: () => _editAmount(item),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.recurringEditAmount),
                  ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.expense),
                  onPressed: () => _delete(item),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.commonDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  final double initialAmount;

  const _AmountDialog({required this.initialAmount});

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(text: Formatters.groupDigits(widget.initialAmount));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value, AppLocalizations l10n) {
    final double? amount = Validators.parseAmount(value);
    if (!Validators.isPositiveAmount(amount)) return l10n.validationAmountPositive;
    return Validators.isWithinMaxAmount(amount!) ? null : l10n.validationAmountMax;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(Validators.parseAmount(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.recurringEditAmount),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsInputFormatter()],
          validator: (value) => _validate(value, l10n),
          decoration: const InputDecoration(suffixText: '₫'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
