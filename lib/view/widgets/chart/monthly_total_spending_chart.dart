import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/monthly_total_spending.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mi_garaje/shared/utils/statics.dart';

class MonthlyTotalSpendingChart extends StatefulWidget {
  final List<MonthlyTotalSpending> data;
  final String selectedYear;

  const MonthlyTotalSpendingChart(
      {super.key, required this.data, required this.selectedYear});

  @override
  State<MonthlyTotalSpendingChart> createState() =>
      _MonthlyTotalSpendingChartState();
}

class _MonthlyTotalSpendingChartState extends State<MonthlyTotalSpendingChart> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final List<MonthlyTotalSpending> yearData =
        Statics.generateMonthlyDataForYear(widget.data, widget.selectedYear);

    final maxTotal =
        yearData.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    double maxY = maxTotal > 0 ? ((maxTotal / 50).ceil()) * 50 : 50;
    maxY = maxY == maxTotal ? maxY + (maxY / 10) : maxY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      localizations.monthlyAverageExpense,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )),
          ],
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.03),
        SizedBox(
          height: AppDimensions.screenHeight(context) * 0.45,
          child: Stack(children: [
            BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= yearData.length) {
                            return const SizedBox.shrink();
                          }
                          final monthName = DateFormat.MMM('es').format(
                              DateTime(
                                  0,
                                  int.parse(yearData[index]
                                      .monthLabel
                                      .substring(5))));
                          return Text(
                            '${monthName[0].toUpperCase()}${monthName.substring(1)}',
                            style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary),
                          );
                        }),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 22,
                      showTitles: true,
                      interval: maxY / 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary),
                        );
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxY / 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                barGroups: yearData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.total,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                        width: 12,
                      ),
                    ],
                  );
                }).toList(),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
