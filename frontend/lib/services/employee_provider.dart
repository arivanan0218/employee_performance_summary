import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  List<EmployeeData> _employees = [];
  bool _isLoading = false;
  String _error = '';

  List<EmployeeData> get employees => _employees;
  bool get isLoading => _isLoading;
  String get error => _error;

  void setEmployees(List<EmployeeData> employees) {
    _employees = employees;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void updateSummary(String employeeId, String newSummary) {
    final index = _employees.indexWhere((emp) => emp.employeeId == employeeId);
    if (index != -1) {
      _employees[index].summary = newSummary;
      notifyListeners();
    }
  }

  // Get departments for analytics
  List<String> get departments {
    return _employees.map((e) => e.department).toSet().toList();
  }

  // Get average goals met by department
  Map<String, double> getAverageGoalsByDepartment() {
    Map<String, List<double>> deptGoals = {};

    for (var emp in _employees) {
      if (!deptGoals.containsKey(emp.department)) {
        deptGoals[emp.department] = [];
      }
      deptGoals[emp.department]!.add(emp.goalsMet);
    }

    Map<String, double> result = {};
    deptGoals.forEach((dept, goals) {
      double avg = goals.reduce((a, b) => a + b) / goals.length;
      result[dept] = avg;
    });

    return result;
  }

  // Count employees by department
  Map<String, int> getEmployeeCountByDepartment() {
    Map<String, int> result = {};

    for (var emp in _employees) {
      if (!result.containsKey(emp.department)) {
        result[emp.department] = 0;
      }
      result[emp.department] = result[emp.department]! + 1;
    }

    return result;
  }
}
