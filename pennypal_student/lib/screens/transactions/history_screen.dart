import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_record.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/transaction_filter.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

/// S06 Transaction history: search, filters, days with totals, swipe to delete with undo.
class HistoryScreen extends StatefulWidget {
  final List<TransactionRecord>? initialTransactions;

  const HistoryScreen({super.key, this.initialTransactions});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const String _allValue = '';

  final _searchController = TextEditingController();
  late List<TransactionRecord> _transactions = [...(widget.initialTransactions ?? const [])];
  String _query = '';
  String? _type;
  String? _categoryId;
  DateTimeRange? _dateRange = _currentMonthRange();

  static DateTimeRange _currentMonthRange() {
    final DateTime today = DateTime.now();
    return DateTimeRange(start: DateTime(today.year, today.month, 1), end: DateTime(today.year, today.month, today.day));
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTransactions != oldWidget.initialTransactions) {
      _transactions = [...(widget.initialTransactions ?? const [])];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _type = null;
      _categoryId = null;
      _dateRange = null;
    });
  }

  void _removeTransaction(TransactionRecord transaction) {
    final l10n = AppLocalizations.of(context)!;
    final int index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index < 0) return;
    setState(() => _transactions.removeAt(index));

    final String name = transaction.description.isEmpty ? CategoryDisplay.name(l10n, transaction.categoryId) : transaction.description;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.historyDeletedNamed(name)),
        action: SnackBarAction(
          label: l10n.commonUndo,
          textColor: AppColors.mint,
          onPressed: () {
            TransactionService.save(transaction);
            final int safeIndex = index > _transactions.length ? _transactions.length : index;
            setState(() => _transactions.insert(safeIndex, transaction));
          },
        ),
      ));
  }

  Future<bool> _confirmDelete(TransactionRecord transaction) {
    final l10n = AppLocalizations.of(context)!;
    final bool isIncome = transaction.type == TransactionTypes.income;
    final String name = transaction.description.isEmpty ? CategoryDisplay.name(l10n, transaction.categoryId) : transaction.description;
    return showConfirmDialog(
      context,
      title: l10n.txDeleteTitle,
      message: l10n.txDeleteBody(name, Formatters.signedMoney(transaction.amount, isIncome: isIncome)),
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  Future<void> _openDetail(TransactionRecord transaction) async {
    final Object? result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TransactionDetailScreen(transaction: transaction)),
    );
    if (result == FormResults.deleted && mounted) _removeTransaction(transaction);
  }

  void _openAddForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionFormScreen(type: TransactionTypes.expense)),
    );
  }

  Future<String?> _pickOption(String title, Map<String, String> options, String selected) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(title, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              ...options.entries.map((option) => ListTile(
                    title: Text(option.value),
                    trailing: option.key == selected ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () => Navigator.of(sheetContext).pop(option.key),
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickType() async {
    final l10n = AppLocalizations.of(context)!;
    final String? picked = await _pickOption(
      l10n.detailType,
      {_allValue: l10n.filterAllTypes, TransactionTypes.expense: l10n.filterExpense, TransactionTypes.income: l10n.filterIncome},
      _type ?? _allValue,
    );
    if (picked == null) return;
    setState(() => _type = picked == _allValue ? null : picked);
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final List<String> categoryIds = [...CategoryKeys.selectableExpense, CategoryKeys.savings, ...CategoryKeys.income];
    final Map<String, String> options = {_allValue: l10n.filterAllCategories};
    for (final String categoryId in categoryIds) {
      options[categoryId] = CategoryDisplay.name(l10n, categoryId);
    }
    final String? picked = await _pickOption(l10n.txCategory, options, _categoryId ?? _allValue);
    if (picked == null) return;
    setState(() => _categoryId = picked == _allValue ? null : picked);
  }

  Future<void> _pickDateRange() async {
    final DateTime today = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
      initialDateRange: _dateRange,
    );
    if (picked == null) return;
    setState(() => _dateRange = picked);
  }

  String _dayLabel(AppLocalizations l10n, DateTime day) {
    final DateTime today = DateTime.now();
    final DateTime todayStart = DateTime(today.year, today.month, today.day);
    final int daysAgo = todayStart.difference(day).inDays;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String name = daysAgo == 0
        ? l10n.commonToday
        : (daysAgo == 1 ? l10n.commonYesterday : DateFormat.EEEE(languageCode).format(day));
    return '$name · ${DateFormat('dd/MM').format(day)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<TransactionRecord> filtered = TransactionFilter.apply(
      _transactions,
      query: _query,
      type: _type,
      categoryId: _categoryId,
      from: _dateRange?.start,
      to: _dateRange?.end,
    );
    final List<DayGroup> groups = TransactionFilter.groupByDay(filtered);
    final String typeLabel = switch (_type) {
      TransactionTypes.expense => l10n.filterExpense,
      TransactionTypes.income => l10n.filterIncome,
      _ => l10n.filterAllTypes,
    };
    final DateTimeRange? range = _dateRange;
    final String dateLabel = range == null
        ? l10n.filterAllDates
        : '${DateFormat('dd/MM').format(range.start)} – ${DateFormat('dd/MM').format(range.end)}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.navTransactions,
                      style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(52, 52),
                    ),
                    tooltip: l10n.historyAddTransaction,
                    onPressed: _openAddForm,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.historySearchHint,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  fillColor: AppColors.fill,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.commonClearFilter,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  _FilterButton(icon: Icons.expand_more, label: typeLabel, isActive: _type != null, onTap: _pickType),
                  const SizedBox(width: 8),
                  _FilterButton(
                    icon: Icons.sell_outlined,
                    label: _categoryId == null ? l10n.txCategory : CategoryDisplay.name(l10n, _categoryId!),
                    isActive: _categoryId != null,
                    onTap: _pickCategory,
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(icon: Icons.calendar_today_outlined, label: dateLabel, isActive: range != null, onTap: _pickDateRange),
                ],
              ),
            ),
            Expanded(
              child: groups.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      message: l10n.historyEmpty,
                      actionLabel: l10n.commonClearFilter,
                      onAction: _clearFilters,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: groups.length,
                      itemBuilder: (context, index) => _buildDayGroup(l10n, groups[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGroup(AppLocalizations l10n, DayGroup group) {
    final bool isPositive = group.netTotal >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _dayLabel(l10n, group.day),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
              Text(
                Formatters.signedMoney(group.netTotal.abs(), isIncome: isPositive),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: group.transactions.map((transaction) {
              return Dismissible(
                key: ValueKey(transaction.id),
                direction: transaction.isGoalContribution ? DismissDirection.none : DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(transaction),
                onDismissed: (_) {
                  TransactionService.delete(transaction.id);
                  _removeTransaction(transaction);
                },
                background: Container(
                  color: AppColors.expense,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.white),
                      Text(l10n.commonDelete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TransactionTile(
                    transaction: transaction,
                    showPaymentMode: true,
                    onTap: () => _openDetail(transaction),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color foreground = isActive ? Colors.white : AppColors.textPrimary;

    return Material(
      color: isActive ? AppColors.textPrimary : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: isActive ? AppColors.textPrimary : AppColors.border, width: 1.5)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
