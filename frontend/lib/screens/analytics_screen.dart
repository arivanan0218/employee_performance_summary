import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/employee_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employees = employeeProvider.employees;

    if (employees.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(
          child: Text('Upload employee data to view analytics'),
        ),
      );
    }

    final deptGoals = employeeProvider.getAverageGoalsByDepartment();
    final deptCounts = employeeProvider.getEmployeeCountByDepartment();

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Analytics Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Department Performance Chart
            _buildSectionTitle('Average Goals Met by Department'),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDepartmentGoalsChart(deptGoals),
              ),
            ),
            const SizedBox(height: 32),

            // Department Distribution Pie Chart
            _buildSectionTitle('Employee Distribution by Department'),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDepartmentDistributionChart(deptCounts),
              ),
            ),

            const SizedBox(height: 32),

            // Performance Distribution
            _buildSectionTitle('Performance Distribution'),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildPerformanceDistributionChart(employees),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDepartmentGoalsChart(Map<String, double> deptGoals) {
    final deptEntries = deptGoals.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${deptEntries[groupIndex].key}: ${rod.toY.toStringAsFixed(1)}%',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= deptEntries.length)
                  return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    deptEntries[value.toInt()].key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString() + '%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(deptEntries.length, (index) {
          final entry = deptEntries[index];
          Color barColor;
          if (entry.value >= 90) {
            barColor = Colors.green.shade700;
          } else if (entry.value >= 75) {
            barColor = Colors.green.shade400;
          } else if (entry.value >= 60) {
            barColor = Colors.orange.shade400;
          } else {
            barColor = Colors.red.shade400;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: barColor,
                width: 25,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDepartmentDistributionChart(Map<String, int> deptCounts) {
    final deptEntries = deptCounts.entries.toList();
    final totalEmployees = deptCounts.values.reduce((a, b) => a + b);

    return PieChart(
      PieChartData(
        sections: List.generate(deptEntries.length, (index) {
          final entry = deptEntries[index];
          final percentage = entry.value / totalEmployees * 100;

          return PieChartSectionData(
            color:
                [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.purple,
                  Colors.orange,
                  Colors.teal,
                ][index % 6],
            value: entry.value.toDouble(),
            title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
      ),
    );
  }

  Widget _buildPerformanceDistributionChart(List<dynamic> employees) {
    // Categorize employees by performance
    final Map<String, int> performanceDistribution = {
      'Excellent (90-100%)': 0,
      'Good (75-89%)': 0,
      'Average (60-74%)': 0,
      'Needs Improvement (<60%)': 0,
    };

    for (var emp in employees) {
      final goalsMet = emp.goalsMet;
      if (goalsMet >= 90) {
        performanceDistribution['Excellent (90-100%)'] =
            performanceDistribution['Excellent (90-100%)']! + 1;
      } else if (goalsMet >= 75) {
        performanceDistribution['Good (75-89%)'] =
            performanceDistribution['Good (75-89%)']! + 1;
      } else if (goalsMet >= 60) {
        performanceDistribution['Average (60-74%)'] =
            performanceDistribution['Average (60-74%)']! + 1;
      } else {
        performanceDistribution['Needs Improvement (<60%)'] =
            performanceDistribution['Needs Improvement (<60%)']! + 1;
      }
    }

    final categories = performanceDistribution.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= categories.length)
                  return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    categories[value.toInt()],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(categories.length, (index) {
          final category = categories[index];
          final count = performanceDistribution[category]!;

          Color barColor;
          switch (index) {
            case 0:
              barColor = Colors.green.shade700;
              break;
            case 1:
              barColor = Colors.green.shade400;
              break;
            case 2:
              barColor = Colors.orange.shade400;
              break;
            default:
              barColor = Colors.red.shade400;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: barColor,
                width: 25,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
