import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_record.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/report_calculator.dart';
import '../../utils/sample_data.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/month_picker.dart';
import '../../widgets/summary_card.dart';
import '../transactions/transaction_form_screen.dart';

class ReportsScreen extends StatefulWidget {
  final List<TransactionRecord>? transactions;

  const ReportsScreen({super.key, this.transactions});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const int _topCount = 3;

  late final List<TransactionRecord> _transactions =
      widget.transactions ?? [...SampleData.transactions(), ...SampleData.pastMonthsTransactions()];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _openAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionFormScreen(type: TransactionTypes.expense)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final MonthSummary summary = ReportCalculator.summary(_transactions, _month);
    final List<CategoryTotal> byCategory = ReportCalculator.spendingByCategory(_transactions, _month);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.menuReports, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          MonthPicker(month: _month, onChanged: (month) => setState(() => _month = month)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: l10n.dashMonthIncome,
                  value: Formatters.money(summary.income),
                  icon: Icons.arrow_downward,
                  color: AppColors.primary,
                  backgroundColor: AppColors.mintSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: l10n.dashMonthExpense,
                  value: Formatters.money(summary.spending),
                  icon: Icons.arrow_upward,
                  color: AppColors.expense,
                  backgroundColor: AppColors.expenseSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: l10n.dashMonthSavings,
                  value: Formatters.money(summary.savings),
                  icon: Icons.savings_outlined,
                  color: AppColors.honeyText,
                  backgroundColor: AppColors.honeySoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (summary.isEmpty)
            _buildEmpty(l10n, languageCode)
          else ...[
            _buildCategoryCard(l10n, languageCode, summary, byCategory),
            const SizedBox(height: 16),
            _buildTrendCard(l10n, languageCode),
            if (byCategory.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(l10n.reportsTop, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _buildTopCard(l10n, byCategory.take(_topCount).toList()),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, String languageCode) {
    final DateTime previousMonth = DateTime(_month.year, _month.month - 1);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(color: AppColors.fill, shape: BoxShape.circle),
                  child: Image.asset(AppAssets.pig, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),
                Text(l10n.reportsNoData, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  l10n.reportsNoDataBody(Formatters.monthLabel(_month, languageCode)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.textPrimary),
                  onPressed: _openAddExpense,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dashAddExpense),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => _month = previousMonth),
          icon: const Icon(Icons.chevron_left),
          label: Text(l10n.reportsSeeMonth(Formatters.monthLabel(previousMonth, languageCode))),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(AppLocalizations l10n, String languageCode, MonthSummary summary, List<CategoryTotal> byCategory) {
    final NumberFormat percentFormat = NumberFormat('0.0', languageCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportsByCategory, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (byCategory.isEmpty)
              Text(l10n.reportsNoSpending, style: const TextStyle(color: AppColors.textSecondary))
            else ...[
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 58,
                        sectionsSpace: 2,
                        sections: byCategory
                            .map((item) => PieChartSectionData(
                                  value: item.amount,
                                  color: CategoryDisplay.chartColor(item.categoryId),
                                  radius: 38,
                                  showTitle: false,
                                ))
                            .toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.reportsTotalSpending, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(
                          Formatters.money(summary.spending),
                          style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...byCategory.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: CategoryDisplay.chartColor(item.categoryId), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(CategoryDisplay.name(l10n, item.categoryId), style: const TextStyle(fontSize: 15))),
                        Text(Formatters.money(item.amount), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 56,
                          child: Text(
                            '${percentFormat.format(item.percent)}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(AppLocalizations l10n, String languageCode) {
    final List<MonthTotal> totals = ReportCalculator.monthlyTotals(_transactions, _month);
    final MonthTotal current = totals.last;
    double maxValue = 0;
    for (final MonthTotal total in totals) {
      if (total.income > maxValue) maxValue = total.income;
      if (total.spending > maxValue) maxValue = total.spending;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.reportsTrend, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                _Legend(color: AppColors.mint, label: l10n.dashMonthIncome),
                const SizedBox(width: 10),
                _Legend(color: AppColors.pink, label: l10n.dashMonthExpense),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: BarChart(
                BarChartData(
                  maxY: maxValue == 0 ? 1 : maxValue * 1.1,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final DateTime month = totals[value.toInt()].month;
                          final bool isCurrent = value.toInt() == totals.length - 1;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat.MMM(languageCode).format(month),
                              style: TextStyle(fontSize: 12, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (int index = 0; index < totals.length; index++)
                      BarChartGroupData(
                        x: index,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(toY: totals[index].income, color: AppColors.mint, width: 12),
                          BarChartRodData(toY: totals[index].spending, color: AppColors.pink, width: 12),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reportsTrendSummary(
                Formatters.monthLabel(current.month, languageCode),
                Formatters.money(current.income),
                Formatters.money(current.spending),
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(AppLocalizations l10n, List<CategoryTotal> top) {
    return Card(
      child: Column(
        children: [
          for (int index = 0; index < top.length; index++)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: index == 0 ? AppColors.honey : AppColors.fill,
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ),
                  const SizedBox(width: 12),
                  CategoryIcon(
                    iconName: CategoryDisplay.iconName(top[index].categoryId),
                    color: CategoryDisplay.color(top[index].categoryId),
                    backgroundColor: CategoryDisplay.softColor(top[index].categoryId),
                    size: 40,
                  ),
                ],
              ),
              title: Text(CategoryDisplay.name(l10n, top[index].categoryId), style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: Text(
                Formatters.money(top[index].amount),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
