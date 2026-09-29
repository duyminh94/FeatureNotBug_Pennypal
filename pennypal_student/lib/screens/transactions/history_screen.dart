import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/transaction_record.dart';
import '../../controllers/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/transaction_filter.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/month_picker.dart';
import '../../widgets/transaction_tile.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class HistoryScreen extends StatefulWidget {
  final List<TransactionRecord>? initialTransactions;
  final DateTime? initialMonth;

  const HistoryScreen({super.key, this.initialTransactions, this.initialMonth});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const String _allValue = '';
  static const int _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();
  late List<TransactionRecord> _transactions = [...(widget.initialTransactions ?? const [])];
  late DateTime _selectedMonth = widget.initialMonth ?? DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
  String _query = '';
  String? _type;
  String? _categoryId;
  int _visibleCount = _pageSize;

  bool get _isCurrentMonth {
    final DateTime now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  bool get _hasActiveFilters =>
      _query.isNotEmpty || _type != null || _categoryId != null || _selectedDay != null;

  List<TransactionRecord> get _monthTransactions {
    return TransactionFilter.forMonth(_transactions, _selectedMonth);
  }

  double get _monthIncome {
    return _monthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _monthExpense {
    return _monthTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _monthNet => _monthIncome - _monthExpense;

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

  void _changeFilter(VoidCallback change) {
    setState(() {
      change();
      _visibleCount = _pageSize;
    });
  }

  void _clearFilters() {
    _searchController.clear();
    _changeFilter(() {
      _query = '';
      _type = null;
      _categoryId = null;
      _selectedDay = null;
    });
  }

  void _onMonthChanged(DateTime newMonth) {
    _changeFilter(() {
      _selectedMonth = DateTime(newMonth.year, newMonth.month);
      _selectedDay = null;
    });
  }

  void _removeTransaction(TransactionRecord transaction) {
    final l10n = AppLocalizations.of(context)!;
    final int index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index < 0) return;
    setState(() => _transactions.removeAt(index));

    final String name = transaction.description.isEmpty
        ? CategoryDisplay.name(l10n, transaction.categoryId)
        : transaction.description;
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
    final String name = transaction.description.isEmpty
        ? CategoryDisplay.name(l10n, transaction.categoryId)
        : transaction.description;
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

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final List<String> categoryIds = [...CategoryKeys.selectableExpense, CategoryKeys.savings, ...CategoryKeys.income];
    final Map<String, String> options = {_allValue: l10n.filterAllCategories};
    for (final String categoryId in categoryIds) {
      options[categoryId] = CategoryDisplay.name(l10n, categoryId);
    }
    final String? picked = await _pickOption(l10n.txCategory, options, _categoryId ?? _allValue);
    if (picked == null) return;
    _changeFilter(() => _categoryId = picked == _allValue ? null : picked);
  }

  Future<void> _pickDay() async {
    final DateTime start = TransactionFilter.monthStart(_selectedMonth);
    final DateTime end = TransactionFilter.monthEnd(_selectedMonth);
    final DateTime now = DateTime.now();
    DateTime initial = _selectedDay ?? (_isCurrentMonth ? now : start);
    if (initial.isBefore(start)) initial = start;
    if (initial.isAfter(end)) initial = end;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: start,
      lastDate: end,
    );
    if (picked == null) return;
    _changeFilter(() => _selectedDay = picked);
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
    final String languageCode = Localizations.localeOf(context).languageCode;

    final DateTime start = _selectedDay ?? TransactionFilter.monthStart(_selectedMonth);
    final DateTime end = _selectedDay ?? TransactionFilter.monthEnd(_selectedMonth);

    final List<TransactionRecord> filtered = TransactionFilter.apply(
      _transactions,
      query: _query,
      type: _type,
      categoryId: _categoryId,
      from: start,
      to: end,
    );

    final List<DayGroup> groups = TransactionFilter.firstGroups(TransactionFilter.groupByDay(filtered), _visibleCount);
    final int hiddenCount = filtered.length - TransactionFilter.countTransactions(groups);

    final String dayLabel = _selectedDay == null
        ? l10n.historyAllDays
        : DateFormat('dd/MM').format(_selectedDay!);

    final String monthText = DateFormat.yMMMM(languageCode).format(_selectedMonth);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(l10n),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: MonthPicker(
                month: _selectedMonth,
                onChanged: _onMonthChanged,
              ),
            ),

            _buildMonthSummaryCard(l10n),

            _buildTypeSegmentedButtons(l10n),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _changeFilter(() => _query = value),
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
                            _changeFilter(() => _query = '');
                          },
                        ),
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              child: Row(
                children: [
                  if (_hasActiveFilters) ...[
                    ActionChip(
                      avatar: const Icon(Icons.close, size: 16, color: AppColors.expense),
                      label: Text(
                        l10n.commonClearFilter,
                        style: const TextStyle(fontSize: 13, color: AppColors.expense, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppColors.expenseSoft,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      onPressed: _clearFilters,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _FilterButton(
                    icon: Icons.sell_outlined,
                    label: _categoryId == null ? l10n.txCategory : CategoryDisplay.name(l10n, _categoryId!),
                    isActive: _categoryId != null,
                    onTap: _pickCategory,
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(
                    icon: Icons.calendar_today_outlined,
                    label: dayLabel,
                    isActive: _selectedDay != null,
                    onTap: _pickDay,
                  ),
                ],
              ),
            ),

            Expanded(
              child: groups.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: _hasActiveFilters ? l10n.historyEmpty : l10n.historyMonthEmpty(monthText),
                      actionLabel: _hasActiveFilters ? l10n.commonClearFilter : l10n.historyAddTransaction,
                      onAction: _hasActiveFilters ? _clearFilters : _openAddForm,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: hiddenCount > 0 ? groups.length + 1 : groups.length,
                      itemBuilder: (context, index) {
                        if (index < groups.length) return _buildDayGroup(l10n, groups[index]);
                        return _buildShowMore(l10n, hiddenCount);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.navTransactions,
              style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 32, fontWeight: FontWeight.w800),
            ),
          ),
          if (!_isCurrentMonth) ...[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.fill,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _onMonthChanged(DateTime(DateTime.now().year, DateTime.now().month)),
              child: Text(
                l10n.historyThisMonth,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
            tooltip: l10n.historyAddTransaction,
            onPressed: _openAddForm,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummaryCard(AppLocalizations l10n) {
    final double income = _monthIncome;
    final double expense = _monthExpense;
    final double net = _monthNet;
    final int count = _monthTransactions.length;

    final bool isIncomeSelected = _type == TransactionTypes.income;
    final bool isExpenseSelected = _type == TransactionTypes.expense;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: isIncomeSelected ? AppColors.mintSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      _changeFilter(() {
                        _type = isIncomeSelected ? null : TransactionTypes.income;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isIncomeSelected ? AppColors.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isIncomeSelected ? AppColors.surface : AppColors.mintSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_downward_rounded, size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dashMonthIncome,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '+${Formatters.money(income)}',
                                    style: const TextStyle(
                                      fontFamily: AppFonts.heading,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              const SizedBox(width: 6),
              Expanded(
                child: Material(
                  color: isExpenseSelected ? AppColors.expenseSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      _changeFilter(() {
                        _type = isExpenseSelected ? null : TransactionTypes.expense;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isExpenseSelected ? AppColors.expense : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isExpenseSelected ? AppColors.surface : AppColors.expenseSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, size: 18, color: AppColors.expense),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dashMonthExpense,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '-${Formatters.money(expense)}',
                                    style: const TextStyle(
                                      fontFamily: AppFonts.heading,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.expense,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (_type != null) _changeFilter(() => _type = null);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${l10n.reportsBalance}: ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ),
                          Text(
                            Formatters.signedMoney(net.abs(), isIncome: net >= 0),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: net >= 0 ? AppColors.primary : AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.historyTxCount(count),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSegmentedButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      child: SegmentedButton<String?>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              if (_type == TransactionTypes.expense) return AppColors.expenseSoft;
              if (_type == TransactionTypes.income) return AppColors.mintSoft;
              return AppColors.textPrimary;
            }
            return AppColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              if (_type == TransactionTypes.expense) return AppColors.expense;
              if (_type == TransactionTypes.income) return AppColors.primary;
              return Colors.white;
            }
            return AppColors.textSecondary;
          }),
          side: WidgetStateProperty.all(const BorderSide(color: AppColors.border)),
        ),
        segments: [
          ButtonSegment<String?>(
            value: null,
            label: Text(l10n.filterAllTypes, style: const TextStyle(fontWeight: FontWeight.w700)),
            icon: const Icon(Icons.list_alt_rounded, size: 16),
          ),
          ButtonSegment<String?>(
            value: TransactionTypes.expense,
            label: Text(l10n.filterExpense, style: const TextStyle(fontWeight: FontWeight.w700)),
            icon: const Icon(Icons.arrow_upward_rounded, size: 16),
          ),
          ButtonSegment<String?>(
            value: TransactionTypes.income,
            label: Text(l10n.filterIncome, style: const TextStyle(fontWeight: FontWeight.w700)),
            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
          ),
        ],
        selected: {_type},
        onSelectionChanged: (selected) {
          _changeFilter(() => _type = selected.first);
        },
      ),
    );
  }

  Widget _buildShowMore(AppLocalizations l10n, int hiddenCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OutlinedButton(
        onPressed: () => setState(() => _visibleCount += _pageSize),
        child: Text(l10n.historyShowMore(hiddenCount)),
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
