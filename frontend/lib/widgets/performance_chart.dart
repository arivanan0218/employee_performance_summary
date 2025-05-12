import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/employee_model.dart';

class PerformanceChart extends StatefulWidget {
  final List<EmployeeData> employees;

  const PerformanceChart({super.key, required this.employees});

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Performance categories
    final excellentCount =
        widget.employees.where((e) => e.goalsMet >= 90).length;
    final goodCount =
        widget.employees
            .where((e) => e.goalsMet >= 75 && e.goalsMet < 90)
            .length;
    final averageCount =
        widget.employees
            .where((e) => e.goalsMet >= 60 && e.goalsMet < 75)
            .length;
    final improvementCount =
        widget.employees.where((e) => e.goalsMet < 60).length;

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: showingSections(),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIndicator('Excellent', Colors.green, excellentCount),
            const SizedBox(height: 16),
            _buildIndicator('Good', Colors.blue, goodCount),
            const SizedBox(height: 16),
            _buildIndicator('Average', Colors.orange, averageCount),
            const SizedBox(height: 16),
            _buildIndicator('Needs Improvement', Colors.red, improvementCount),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    // Performance categories
    final excellentCount =
        widget.employees.where((e) => e.goalsMet >= 90).length;
    final goodCount =
        widget.employees
            .where((e) => e.goalsMet >= 75 && e.goalsMet < 90)
            .length;
    final averageCount =
        widget.employees
            .where((e) => e.goalsMet >= 60 && e.goalsMet < 75)
            .length;
    final improvementCount =
        widget.employees.where((e) => e.goalsMet < 60).length;

    final total = widget.employees.length;

    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 80.0 : 70.0;
      final fontSize = isTouched ? 16.0 : 14.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: excellentCount.toDouble(),
            title: ((excellentCount / total) * 100).toStringAsFixed(1) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: goodCount.toDouble(),
            title: ((goodCount / total) * 100).toStringAsFixed(1) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.orange,
            value: averageCount.toDouble(),
            title: ((averageCount / total) * 100).toStringAsFixed(1) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.red,
            value: improvementCount.toDouble(),
            title: ((improvementCount / total) * 100).toStringAsFixed(1) + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  Widget _buildIndicator(String title, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              '$count ${count == 1 ? 'Employee' : 'Employees'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
