import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/employee_provider.dart';
import '../models/employee_model.dart';
import '../utils/pdf_generator.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, bool> _expandedItems = {};
  Map<String, TextEditingController> _summaryControllers = {};

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

    if (employees.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Performance Summaries')),
        body: const Center(child: Text('No summaries generated yet')),
      );
    }

    // Group employees by department
    Map<String, List<EmployeeData>> departmentGroups = {};
    for (var emp in employees) {
      if (emp.department.isEmpty) continue; // Skip if department is empty

      if (!departmentGroups.containsKey(emp.department)) {
        departmentGroups[emp.department] = [];
      }
      departmentGroups[emp.department]!.add(emp);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Summaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed:
                () => PdfGenerator.generateAndSavePdf(context, employees),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (departmentGroups.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Error: Summaries were generated but no valid departments were found.',
                style: TextStyle(color: Colors.red),
              ),
            ),

          ...departmentGroups.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[200],
                  child: Text(
                    '${entry.key} Department (${entry.value.length} ${entry.value.length == 1 ? 'Employee' : 'Employees'})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...entry.value.map(
                  (emp) => _buildEmployeeCard(emp, employeeProvider),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeData emp, EmployeeProvider provider) {
    final bool isExpanded = _expandedItems[emp.employeeId] ?? false;
    final controller =
        _summaryControllers[emp.employeeId] ??
        TextEditingController(text: emp.summary);

    // Make sure the controller exists
    if (!_summaryControllers.containsKey(emp.employeeId)) {
      _summaryControllers[emp.employeeId] = controller;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              emp.employeeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('ID: ${emp.employeeId} | Month: ${emp.month}'),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expandedItems[emp.employeeId] = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Department', emp.department),
                  _buildInfoRow('Goals Met', '${emp.goalsMet}%'),
                  _buildInfoRow('Tasks Completed', emp.tasksCompleted),
                  if (emp.peerFeedback != null && emp.peerFeedback!.isNotEmpty)
                    _buildInfoRow('Peer Feedback', emp.peerFeedback!),
                  if (emp.managerComments != null &&
                      emp.managerComments!.isNotEmpty)
                    _buildInfoRow('Manager Comments', emp.managerComments!),
                  const SizedBox(height: 10),
                  const Text(
                    'Performance Summary:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'AI-generated summary',
                    ),
                    onChanged: (value) {
                      provider.updateSummary(emp.employeeId, value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
