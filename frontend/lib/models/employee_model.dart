class EmployeeData {
  final String employeeName;
  final String employeeId;
  final String department;
  final String month;
  final String tasksCompleted;
  final double goalsMet;
  final String? peerFeedback;
  final String? managerComments;
  String summary;

  EmployeeData({
    required this.employeeName,
    required this.employeeId,
    required this.department,
    required this.month,
    required this.tasksCompleted,
    required this.goalsMet,
    this.peerFeedback,
    this.managerComments,
    this.summary = '',
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      employeeName: json['employee_name'] ?? 'Unknown',
      employeeId: json['employee_id'] ?? 'Unknown',
      department: json['department'] ?? 'Unknown',
      month: json['month'] ?? 'Unknown',
      tasksCompleted: json['tasks_completed'] ?? 'None',
      goalsMet: _parseGoalsMet(json['goals_met']),
      peerFeedback: json['peer_feedback'],
      managerComments: json['manager_comments'],
      summary: json['summary'] ?? '',
    );
  }

  // Helper to parse goals_met safely
  static double _parseGoalsMet(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_name': employeeName,
      'employee_id': employeeId,
      'department': department,
      'month': month,
      'tasks_completed': tasksCompleted,
      'goals_met': goalsMet,
      'peer_feedback': peerFeedback,
      'manager_comments': managerComments,
      'summary': summary,
    };
  }
}
