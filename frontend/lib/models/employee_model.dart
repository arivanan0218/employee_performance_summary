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
    // Print the incoming JSON for debugging
    print('Processing employee JSON: $json');

    // Extract tasks_completed - ensure it's not null or empty
    String tasksCompleted = 'None';
    if (json['tasks_completed'] != null &&
        json['tasks_completed'].toString().trim().isNotEmpty) {
      tasksCompleted = json['tasks_completed'].toString();
    }

    // Extract and parse goals_met safely
    double goalsMet = 0.0;
    if (json['goals_met'] != null) {
      if (json['goals_met'] is num) {
        goalsMet = (json['goals_met'] as num).toDouble();
      } else if (json['goals_met'] is String) {
        try {
          goalsMet = double.parse(json['goals_met'].toString());
        } catch (e) {
          print('Error parsing goals_met: ${json['goals_met']}');
        }
      }
    }

    return EmployeeData(
      employeeName: json['employee_name']?.toString() ?? 'Unknown',
      employeeId: json['employee_id']?.toString() ?? 'Unknown',
      department: json['department']?.toString() ?? 'Unknown',
      month: json['month']?.toString() ?? 'Unknown',
      tasksCompleted: tasksCompleted,
      goalsMet: goalsMet,
      peerFeedback: json['peer_feedback']?.toString(),
      managerComments: json['manager_comments']?.toString(),
      summary: json['summary']?.toString() ?? '',
    );
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
