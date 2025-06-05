import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mi_garaje/shared/constants/constants.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> dataMap;

  PieChartWidget({super.key, required this.dataMap});

  final List<Color> _defaultColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

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
                      localizations.distributionByType,
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
        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

        // Gráfica circular
        SizedBox(
          height: AppDimensions.screenHeight(context) * 0.3,
          child: PieChart(
            PieChartData(
              sections: dataMap.entries.map((entry) {
                final value = entry.value;
                final title = entry.key;

                final color = _defaultColors[
                    dataMap.keys.toList().indexOf(title) %
                        _defaultColors.length];

                return PieChartSectionData(
                  value: value,
                  color: color,
                  title: value.toStringAsFixed(0),
                  radius: 100,
                  titlePositionPercentageOffset: 0.7,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),

        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

        // Leyenda
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: dataMap.keys.map((title) {
            final color = _defaultColors[
                dataMap.keys.toList().indexOf(title) % _defaultColors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppDimensions.screenWidth(context) * 0.01),
                Text(title, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
