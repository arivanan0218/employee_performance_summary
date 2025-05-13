import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/employee_provider.dart';
import '../models/employee_model.dart';
import '../utils/pdf_generator.dart';
import 'analytics_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, bool> _expandedItems = {};
  Map<String, TextEditingController> _summaryControllers = {};
  String _searchQuery = '';
  String _filterDepartment = 'All';

  @override
  void initState() {
    super.initState();
    final employees =
        Provider.of<EmployeeProvider>(context, listen: false).employees;

    for (var emp in employees) {
      _expandedItems[emp.employeeId] = false;
      _summaryControllers[emp.employeeId] = TextEditingController(
        text: emp.summary,
      );
    }
  }

  @override
  void dispose() {
    _summaryControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employees = employeeProvider.employees;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (employees.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Performance Summaries')),
        body: const Center(child: Text('No summaries generated yet')),
      );
    }

    // Get unique departments for filtering
    final departments = [
      'All',
      ...employees.map((e) => e.department).toSet().toList(),
    ];

    // Filter employees based on search and department filter
    final filteredEmployees = employees.where((emp) {
      final matchesSearch = emp.employeeName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
          emp.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDepartment =
          _filterDepartment == 'All' || emp.department == _filterDepartment;

      return matchesSearch && matchesDepartment;
    }).toList();

    // Group filtered employees by department
    Map<String, List<EmployeeData>> departmentGroups = {};
    for (var emp in filteredEmployees) {
      if (emp.department.isEmpty) continue; // Skip if department is empty

      if (!departmentGroups.containsKey(emp.department)) {
        departmentGroups[emp.department] = [];
      }
      departmentGroups[emp.department]!.add(emp);
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  tooltip: 'View Analytics',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Export to PDF',
                  onPressed: () => PdfGenerator.generateAndSavePdf(
                    context,
                    filteredEmployees,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Performance Summaries',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -20,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchFilterHeaderDelegate(
                searchQuery: _searchQuery,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                departments: departments,
                selectedDepartment: _filterDepartment,
                onDepartmentChanged: (value) {
                  setState(() {
                    _filterDepartment = value;
                  });
                },
                totalEmployees: filteredEmployees.length,
              ),
            ),
          ];
        },
        body: filteredEmployees.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text('No results found', style: textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...departmentGroups.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8, top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key} Department',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entry.value.length} ${entry.value.length == 1 ? 'Employee' : 'Employees'}',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map(
                          (emp) => _buildEmployeeCard(emp, employeeProvider),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            PdfGenerator.generateAndSavePdf(context, filteredEmployees),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export to PDF'),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeData emp, EmployeeProvider provider) {
    final bool isExpanded = _expandedItems[emp.employeeId] ?? false;
    final controller = _summaryControllers[emp.employeeId] ??
        TextEditingController(text: emp.summary);

    // Make sure the controller exists
    if (!_summaryControllers.containsKey(emp.employeeId)) {
      _summaryControllers[emp.employeeId] = controller;
    }

    // Format goals_met properly
    final goalsMetFormatted = '${emp.goalsMet.toStringAsFixed(1)}%';

    // Performance color based on goals met
    Color performanceColor;
    String performanceLevel;

    if (emp.goalsMet >= 90) {
      performanceColor = Colors.green;
      performanceLevel = 'Excellent';
    } else if (emp.goalsMet >= 75) {
      performanceColor = Colors.blue;
      performanceLevel = 'Good';
    } else if (emp.goalsMet >= 60) {
      performanceColor = Colors.orange;
      performanceLevel = 'Average';
    } else {
      performanceColor = Colors.red;
      performanceLevel = 'Needs Improvement';
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: performanceColor, width: 4),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      emp.employeeName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: performanceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: performanceColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 14,
                          color: performanceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          performanceLevel,
                          style: textTheme.bodySmall?.copyWith(
                            color: performanceColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: ${emp.employeeId}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      emp.month,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.track_changes,
                      size: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      goalsMetFormatted,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_right),
                ),
                onPressed: () {
                  setState(() {
                    _expandedItems[emp.employeeId] = !isExpanded;
                  });
                },
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.assignment_turned_in,
                              'Goals Met',
                              goalsMetFormatted,
                              barValue: emp.goalsMet / 100,
                              barColor: performanceColor,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoTile(
                              Icons.task_alt,
                              'Tasks Completed',
                              emp.tasksCompleted,
                            ),
                            if (emp.peerFeedback != null &&
                                emp.peerFeedback!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildInfoTile(
                                Icons.people,
                                'Peer Feedback',
                                emp.peerFeedback!,
                              ),
                            ],
                            if (emp.managerComments != null &&
                                emp.managerComments!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildInfoTile(
                                Icons.supervisor_account,
                                'Manager Comments',
                                emp.managerComments!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Performance Summary',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'AI-generated summary',
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    onChanged: (value) {
                      provider.updateSummary(emp.employeeId, value);
                    },
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    double? barValue,
    Color? barColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              if (barValue != null) ...[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barValue,
                      backgroundColor: colorScheme.surfaceVariant,
                      color: barColor ?? colorScheme.primary,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: barColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String content) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
          ),
          child: Text(content, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _SearchFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final List<String> departments;
  final String selectedDepartment;
  final Function(String) onDepartmentChanged;
  final int totalEmployees;

  _SearchFilterHeaderDelegate({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.departments,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.totalEmployees,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: TextEditingController(text: searchQuery),
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search employees',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: departments
                        .map(
                          (dept) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(dept),
                              selected: selectedDepartment == dept,
                              onSelected: (selected) {
                                if (selected) {
                                  onDepartmentChanged(dept);
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalEmployees ${totalEmployees == 1 ? 'result' : 'results'}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(_SearchFilterHeaderDelegate oldDelegate) {
    return searchQuery != oldDelegate.searchQuery ||
        selectedDepartment != oldDelegate.selectedDepartment ||
        totalEmployees != oldDelegate.totalEmployees;
  }
}
