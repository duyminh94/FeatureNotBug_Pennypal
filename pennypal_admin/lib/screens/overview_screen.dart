import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/support_query.dart';
import '../utils/admin_section.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/overview_calculator.dart';
import '../utils/sample_data.dart';

class OverviewScreen extends StatelessWidget {
  static const int mobileRequestCount = 3;
  static const double chartBreakpoint = 1000;
  static const double statCardHeight = 170;

  final AdminData data;
  final ValueChanged<AdminSection> onOpenSection;
  final DateTime? now;

  const OverviewScreen({super.key, required this.data, required this.onOpenSection, this.now});

  String _greeting(AppLocalizations l10n, DateTime time) {
    if (time.hour < 12) return l10n.overviewGreetingMorning;
    return time.hour < 18 ? l10n.overviewGreetingAfternoon : l10n.overviewGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final DateTime today = now ?? DateTime.now();
    final OverviewStats stats = OverviewCalculator.compute(data, today);
    final List<SupportQuery> openQueries = OverviewCalculator.openQueries(data.supportByUser);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 1100 ? 6 : (width >= AdminLayout.wideBreakpoint ? 3 : 2);
        final bool isWide = width >= AdminLayout.wideBreakpoint;

        final List<Widget> cards = [
          _StatCard(
            title: l10n.overviewTotalStudents,
            value: Formatters.count(stats.totalStudents, languageCode),
            caption: l10n.overviewAllRegistered,
            icon: Icons.people_outline,
            color: AppColors.primary,
            background: AppColors.primarySoft,
          ),
          _StatCard(
            title: l10n.overviewNewThisMonth,
            value: Formatters.count(stats.newThisMonth, languageCode),
            caption: Formatters.monthLabel(today, languageCode),
            icon: Icons.arrow_upward,
            color: AppColors.info,
            background: AppColors.infoSoft,
          ),
          _StatCard(
            title: l10n.overviewTransactions,
            value: Formatters.count(stats.transactionsThisMonth, languageCode),
            caption: l10n.overviewThisMonth,
            icon: Icons.format_list_bulleted,
            color: AppColors.textSecondary,
            background: AppColors.fill,
          ),
          _StatCard(
            title: l10n.overviewOpenSupport,
            value: Formatters.count(stats.openSupport, languageCode),
            caption: stats.openSupport == 0 ? l10n.overviewAllReplied : l10n.overviewNeedsReply,
            icon: Icons.support_outlined,
            color: AppColors.error,
            background: AppColors.errorSoft,
          ),
          _StatCard(
            title: l10n.overviewAvgRating,
            value: stats.averageRating == null ? '–' : NumberFormat('0.0', languageCode).format(stats.averageRating),
            caption: stats.averageRating == null ? l10n.overviewNoRatings : null,
            stars: stats.averageRating,
            icon: Icons.star_outline,
            color: AppColors.warning,
            background: const Color(0xFFFFF3C4),
          ),
          _StatCard(
            title: l10n.overviewActiveLessons,
            value: Formatters.count(stats.activeLessons, languageCode),
            caption: l10n.overviewOfLessons(stats.totalLessons),
            icon: Icons.menu_book_outlined,
            color: const Color(0xFF5B4BC4),
            background: const Color(0xFFE9E4FF),
          ),
        ];

        final Widget requests = isWide
            ? _RequestsTable(queries: openQueries, now: today, onReply: () => onOpenSection(AdminSection.support))
            : _RequestsList(
                queries: openQueries.take(mobileRequestCount).toList(),
                now: today,
                onViewAll: () => onOpenSection(AdminSection.support),
              );

        return ListView(
          padding: EdgeInsets.all(isWide ? 28 : 16),
          children: [
            if (!isWide) ...[
              Text(Formatters.dayTitle(today, languageCode), style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(_greeting(l10n, today), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
            ] else ...[
              Text(Formatters.dayTitle(today, languageCode), style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
            ],
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: statCardHeight,
              ),
              children: cards,
            ),
            const SizedBox(height: 20),
            if (isWide)
              width >= chartBreakpoint
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _NewStudentsChart(data: data, now: today, onOpenAnalytics: () => onOpenSection(AdminSection.analytics))),
                        const SizedBox(width: 20),
                        Expanded(child: requests),
                      ],
                    )
                  : Column(
                      children: [
                        _NewStudentsChart(data: data, now: today, onOpenAnalytics: () => onOpenSection(AdminSection.analytics)),
                        const SizedBox(height: 20),
                        requests,
                      ],
                    )
            else
              requests,
          ],
        );
      },
    );
  }
}

String _timeAgo(AppLocalizations l10n, int? millis, DateTime now) {
  if (millis == null) return '';
  final DateTime time = DateTime.fromMillisecondsSinceEpoch(millis);
  final Duration age = now.difference(time);
  if (age.inMinutes < 60) return l10n.commonMinutesAgo(age.inMinutes < 1 ? 1 : age.inMinutes);
  if (age.inHours < 24) return l10n.commonHoursAgo(age.inHours);
  if (age.inHours < 48) return l10n.commonYesterday;
  return DateFormat('dd/MM').format(time);
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? caption;
  final double? stars;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatCard({
    required this.title,
    required this.value,
    this.caption,
    this.stars,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final String? captionText = caption;
    final double? rating = stars;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
            ),
            if (rating != null)
              Row(
                children: [
                  for (int star = 1; star <= 5; star++)
                    Icon(
                      star <= rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18,
                      color: AppColors.star,
                    ),
                ],
              )
            else if (captionText != null)
              Text(captionText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  final List<SupportQuery> queries;
  final DateTime now;
  final VoidCallback onViewAll;

  const _RequestsList({required this.queries, required this.now, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.overviewOpenRequests, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
                TextButton(onPressed: onViewAll, child: Text(l10n.commonViewAll)),
              ],
            ),
            if (queries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.overviewNoOpenRequests, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ...queries.map((query) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: onViewAll,
                  leading: const Icon(Icons.circle, size: 10, color: AppColors.error),
                  minLeadingWidth: 10,
                  title: Text(query.subject, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${query.userEmail} · ${_timeAgo(l10n, query.submittedAt, now)}'),
                  trailing: const Icon(Icons.chevron_right),
                )),
          ],
        ),
      ),
    );
  }
}

class _RequestsTable extends StatelessWidget {
  final List<SupportQuery> queries;
  final DateTime now;
  final VoidCallback onReply;

  const _RequestsTable({required this.queries, required this.now, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.overviewOpenRequests, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    l10n.overviewOpenCount(queries.length),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (queries.isEmpty)
              Text(l10n.overviewNoOpenRequests, style: const TextStyle(color: AppColors.textSecondary))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  columns: [
                    DataColumn(label: Text(l10n.overviewSubject)),
                    DataColumn(label: Text(l10n.overviewStudent)),
                    DataColumn(label: Text(l10n.overviewSubmitted)),
                    const DataColumn(label: SizedBox.shrink()),
                  ],
                  rows: queries
                      .map((query) => DataRow(cells: [
                            DataCell(Text(query.subject, style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataCell(Text(query.userEmail)),
                            DataCell(Text(_timeAgo(l10n, query.submittedAt, now))),
                            DataCell(TextButton(onPressed: onReply, child: Text(l10n.overviewReply))),
                          ]))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewStudentsChart extends StatelessWidget {
  final AdminData data;
  final DateTime now;
  final VoidCallback onOpenAnalytics;

  const _NewStudentsChart({required this.data, required this.now, required this.onOpenAnalytics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final List<MonthCount> counts = OverviewCalculator.newStudentsPerMonth(data.users, now);
    final int maxCount = counts.fold(0, (max, item) => item.count > max ? item.count : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.overviewNewStudentsChart, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
                TextButton(onPressed: onOpenAnalytics, child: Text(l10n.overviewOpenAnalytics)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: (maxCount == 0 ? 1 : maxCount) * 1.25,
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
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(DateFormat.MMM(languageCode).format(counts[value.toInt()].month)),
                        ),
                      ),
                    ),
                  ),
                  barGroups: [
                    for (int index = 0; index < counts.length; index++)
                      BarChartGroupData(
                        x: index,
                        showingTooltipIndicators: const [0],
                        barRods: [
                          BarChartRodData(
                            toY: counts[index].count.toDouble(),
                            color: AppColors.primary,
                            width: 36,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
