import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../services/csv_exporter.dart';
import '../utils/analytics_calculator.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/csv_builder.dart';
import '../utils/formatters.dart';
import '../utils/sample_data.dart';

typedef CsvExport = Future<bool> Function(String fileName, String content);

class AnalyticsScreen extends StatefulWidget {
  static const int pickerMonths = 24;

  final AdminData data;
  final CsvExport exportCsv;
  final DateTime? now;

  const AnalyticsScreen({super.key, required this.data, this.exportCsv = CsvExporter.share, this.now});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final DateTime _today = widget.now ?? DateTime.now();
  late DateTime _from = AnalyticsCalculator.defaultFrom(_today);
  late DateTime _to = AnalyticsCalculator.monthOf(_today);
  bool _isExporting = false;
  bool _showUsersTable = false;

  static const Map<String, Color> _categoryColors = {
    CategoryKeys.food: Color(0xFF0B7A55),
    CategoryKeys.transport: Color(0xFF2563A8),
    CategoryKeys.education: Color(0xFF5B4BC4),
    CategoryKeys.shopping: Color(0xFFD6336C),
    CategoryKeys.entertainment: Color(0xFFE0A800),
    CategoryKeys.bills: Color(0xFF2F6F63),
    CategoryKeys.miscellaneous: Color(0xFF8E8C99),
    AnalyticsCalculator.customKey: Color(0xFFF08A4B),
  };

  String _categoryName(AppLocalizations l10n, String key) {
    return switch (key) {
      CategoryKeys.food => l10n.categoryFood,
      CategoryKeys.transport => l10n.categoryTransport,
      CategoryKeys.education => l10n.categoryEducation,
      CategoryKeys.shopping => l10n.categoryShopping,
      CategoryKeys.entertainment => l10n.categoryEntertainment,
      CategoryKeys.bills => l10n.categoryBills,
      CategoryKeys.miscellaneous => l10n.categoryMiscellaneous,
      _ => l10n.categoryCustom,
    };
  }

  String _millions(double amount, String languageCode) => NumberFormat('0.0', languageCode).format(amount / 1000000);

  Future<void> _export(AppLocalizations l10n, List<DateTime> months, List<int> newUsers, List<MonthlyTransactions> transactions,
      List<CategoryShare> categories) async {
    final String fileName = CsvBuilder.fileName(_from, _to);
    final String content = CsvBuilder.build(
      months: months,
      newUsers: newUsers,
      transactions: transactions,
      categories: categories,
      categoryNames: {for (final CategoryShare share in categories) share.key: _categoryName(l10n, share.key)},
    );

    setState(() => _isExporting = true);
    final bool isDone = await widget.exportCsv(fileName, content);
    if (!mounted) return;
    setState(() => _isExporting = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(isDone ? l10n.analyticsExported(fileName) : l10n.analyticsExportFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final MonthRangeError rangeError = AnalyticsCalculator.checkRange(_from, _to);
    final String? rangeMessage = switch (rangeError) {
      MonthRangeError.reversed => l10n.analyticsRangeReversed,
      MonthRangeError.tooLong => l10n.analyticsRangeTooLong,
      MonthRangeError.none => null,
    };

    final List<DateTime> months = rangeError == MonthRangeError.none ? AnalyticsCalculator.months(_from, _to) : [];
    final List<int> newUsers = AnalyticsCalculator.newUsersPerMonth(widget.data.users, months);
    final List<MonthlyTransactions> transactions = AnalyticsCalculator.transactionsPerMonth(widget.data.transactionsByUser, months);
    final List<CategoryShare> categories = AnalyticsCalculator.spendingByCategory(widget.data.transactionsByUser, months);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRangeCard(l10n, languageCode, rangeMessage, months, newUsers, transactions, categories),
            if (rangeMessage == null) ...[
              const SizedBox(height: 16),
              _buildNewUsersCard(l10n, languageCode, months, newUsers),
              const SizedBox(height: 16),
              _buildTransactionsCard(l10n, languageCode, transactions),
              const SizedBox(height: 16),
              _buildCategoriesCard(l10n, languageCode, months.length, categories),
            ],
          ],
        ),
      ),
    );
  }

  Widget _monthDropdown(String label, DateTime value, ValueChanged<DateTime> onChanged, String languageCode, bool hasError) {
    final List<DateTime> options = [
      for (int back = 0; back < AnalyticsScreen.pickerMonths; back++) DateTime(_today.year, _today.month - back),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<DateTime>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            enabledBorder: hasError
                ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5))
                : null,
          ),
          items: options
              .map((month) => DropdownMenuItem(value: month, child: Text(DateFormat.yMMM(languageCode).format(month))))
              .toList(),
          onChanged: (month) {
            if (month != null) onChanged(month);
          },
        ),
      ],
    );
  }

  Widget _buildRangeCard(AppLocalizations l10n, String languageCode, String? rangeMessage, List<DateTime> months, List<int> newUsers,
      List<MonthlyTransactions> transactions, List<CategoryShare> categories) {
    final bool hasError = rangeMessage != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: _monthDropdown(l10n.analyticsFrom, _from, (month) => setState(() => _from = month), languageCode, hasError)),
                const SizedBox(width: 12),
                Expanded(child: _monthDropdown(l10n.analyticsTo, _to, (month) => setState(() => _to = month), languageCode, hasError)),
              ],
            ),
            const SizedBox(height: 12),
            if (hasError)
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rangeMessage, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
                ],
              )
            else
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(l10n.analyticsRangeHint, style: const TextStyle(color: AppColors.textSecondary)),
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _export(l10n, months, newUsers, transactions, categories),
                    icon: _isExporting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_outlined),
                    label: Text(l10n.analyticsExport),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _barTitle(double value, TitleMeta meta, List<DateTime> months, String languageCode) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(DateFormat.MMM(languageCode).format(months[value.toInt()]), style: const TextStyle(fontSize: 12)),
    );
  }

  FlTitlesData _titles(List<DateTime> months, String languageCode) {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) => _barTitle(value, meta, months, languageCode),
        ),
      ),
    );
  }

  Widget _buildNewUsersCard(AppLocalizations l10n, String languageCode, List<DateTime> months, List<int> newUsers) {
    final int maxCount = newUsers.fold(0, (max, value) => value > max ? value : max);

    return _ChartCard(
      title: l10n.analyticsNewUsers,
      children: [
        SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            maxY: (maxCount == 0 ? 1 : maxCount) * 1.3,
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 4,
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ),
            titlesData: _titles(months, languageCode),
            barGroups: [
              for (int index = 0; index < months.length; index++)
                BarChartGroupData(
                  x: index,
                  showingTooltipIndicators: const [0],
                  barRods: [BarChartRodData(toY: newUsers[index].toDouble(), color: AppColors.primary, width: 24)],
                ),
            ],
          )),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _showUsersTable = !_showUsersTable),
            icon: Icon(_showUsersTable ? Icons.arrow_drop_down : Icons.arrow_right),
            label: Text(_showUsersTable ? l10n.analyticsHideTable : l10n.analyticsShowTable),
          ),
        ),
        if (_showUsersTable)
          _DataGrid(
            headers: [l10n.analyticsMonth, l10n.analyticsUsers],
            rows: [
              for (int index = 0; index < months.length; index++)
                [DateFormat.yMMM(languageCode).format(months[index]), Formatters.count(newUsers[index], languageCode)],
            ],
          ),
      ],
    );
  }

  Widget _buildTransactionsCard(AppLocalizations l10n, String languageCode, List<MonthlyTransactions> transactions) {
    final List<DateTime> months = transactions.map((item) => item.month).toList();
    double maxValue = 0;
    for (final MonthlyTransactions item in transactions) {
      if (item.income > maxValue) maxValue = item.income;
      if (item.expense > maxValue) maxValue = item.expense;
    }

    return _ChartCard(
      title: l10n.analyticsTransactions,
      legend: [
        _LegendItem(color: AppColors.primary, label: l10n.analyticsIncome),
        _LegendItem(color: const Color(0xFFD6336C), label: l10n.analyticsExpense),
      ],
      children: [
        SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            maxY: maxValue == 0 ? 1 : maxValue * 1.1,
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
            titlesData: _titles(months, languageCode),
            barGroups: [
              for (int index = 0; index < transactions.length; index++)
                BarChartGroupData(
                  x: index,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(toY: transactions[index].income, color: AppColors.primary, width: 12),
                    BarChartRodData(toY: transactions[index].expense, color: const Color(0xFFD6336C), width: 12),
                  ],
                ),
            ],
          )),
        ),
        const SizedBox(height: 12),
        _DataGrid(
          headers: [l10n.analyticsMonth, l10n.analyticsIncomeMillion, l10n.analyticsExpenseMillion, l10n.analyticsCount],
          rows: transactions
              .map((item) => [
                    DateFormat.yMMM(languageCode).format(item.month),
                    _millions(item.income, languageCode),
                    _millions(item.expense, languageCode),
                    Formatters.count(item.count, languageCode),
                  ])
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesCard(AppLocalizations l10n, String languageCode, int monthCount, List<CategoryShare> categories) {
    final double total = categories.fold(0, (sum, share) => sum + share.amount);
    final NumberFormat percentFormat = NumberFormat('0', languageCode);

    final Widget chart = SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(PieChartData(
            centerSpaceRadius: 52,
            sectionsSpace: 2,
            sections: categories
                .map((share) => PieChartSectionData(
                      value: share.amount,
                      color: _categoryColors[share.key],
                      radius: 34,
                      showTitle: false,
                    ))
                .toList(),
          )),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.analyticsMonthsLabel(monthCount), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('${_millions(total, languageCode)}M ₫', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );

    final Widget legend = Column(
      children: categories
          .map((share) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: _categoryColors[share.key], borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_categoryName(l10n, share.key))),
                    Text('${percentFormat.format(share.percent)}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ))
          .toList(),
    );

    return _ChartCard(
      title: l10n.analyticsCategories,
      children: [
        if (categories.isEmpty)
          Text(l10n.analyticsNoSpending, style: const TextStyle(color: AppColors.textSecondary))
        else
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 480
                ? Row(children: [chart, const SizedBox(width: 20), Expanded(child: legend)])
                : Column(children: [chart, const SizedBox(height: 12), legend]),
          ),
        const SizedBox(height: 12),
        Text(l10n.analyticsCustomNote, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<Widget> legend;
  final List<Widget> children;

  const _ChartCard({required this.title, this.legend = const [], required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 6,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                if (legend.isNotEmpty) Wrap(spacing: 12, children: legend),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DataGrid extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;

  const _DataGrid({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    TextAlign alignOf(int column) => column == 0 ? TextAlign.left : TextAlign.right;

    return Table(
      border: const TableBorder(horizontalInside: BorderSide(color: AppColors.border)),
      children: [
        TableRow(
          children: [
            for (int column = 0; column < headers.length; column++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  headers[column],
                  textAlign: alignOf(column),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
        for (final List<String> row in rows)
          TableRow(
            children: [
              for (int column = 0; column < row.length; column++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(row[column], textAlign: alignOf(column)),
                ),
            ],
          ),
      ],
    );
  }
}
