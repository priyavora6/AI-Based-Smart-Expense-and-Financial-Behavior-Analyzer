import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../utils/currency_utils.dart';

class SpendingPieChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Map<String, Color> categoryColors;

  const SpendingPieChart({
    super.key,
    required this.categoryData,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Center(
        child: Text('No data available', style: AppTextStyles.bodySmall),
      );
    }

    final total = categoryData.values.fold(0.0, (a, b) => a + b);

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: _buildSections(total),
          centerSpaceRadius: 50,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    return categoryData.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = categoryColors[entry.key] ?? AppColors.catOthers;

      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '${percentage.toStringAsFixed(0)}%',
        titleStyle: AppTextStyles.caption.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        radius: 40,
      );
    }).toList();
  }
}

class SpendingBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  // Each item: {'label': 'Mon', 'income': 500, 'expense': 300}

  const SpendingBarChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available', style: AppTextStyles.bodySmall),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barGroups: _buildBarGroups(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Text(
                      data[index]['label'] ?? '',
                      style: AppTextStyles.caption,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (final item in data) {
      final income = (item['income'] ?? 0).toDouble();
      final expense = (item['expense'] ?? 0).toDouble();
      if (income > max) max = income;
      if (expense > max) max = expense;
    }
    return max * 1.2;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(data.length, (index) {
      final item = data[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (item['income'] ?? 0).toDouble(),
            color: AppColors.success,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: (item['expense'] ?? 0).toDouble(),
            color: AppColors.expense,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }
}