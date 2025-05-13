// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import '../models/employee_model.dart';

// class PdfGenerator {
//   static Future<void> generateAndSavePdf(
//     BuildContext context,
//     List<EmployeeData> employees,
//   ) async {
//     final pdf = pw.Document();

//     // Group employees by department
//     Map<String, List<EmployeeData>> departmentGroups = {};
//     for (var emp in employees) {
//       if (!departmentGroups.containsKey(emp.department)) {
//         departmentGroups[emp.department] = [];
//       }
//       departmentGroups[emp.department]!.add(emp);
//     }

//     // Add title page
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Text(
//                   'Employee Performance Summaries',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Generated on ${DateTime.now().toLocal().toString().split(' ')[0]}',
//                   style: const pw.TextStyle(fontSize: 16),
//                 ),
//                 pw.SizedBox(height: 40),
//                 pw.Text(
//                   'Total Employees: ${employees.length}',
//                   style: const pw.TextStyle(fontSize: 14),
//                 ),
//                 pw.Text(
//                   'Departments: ${departmentGroups.keys.join(', ')}',
//                   style: const pw.TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     // Add department pages
//     for (var entry in departmentGroups.entries) {
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Container(
//                   width: double.infinity,
//                   padding: const pw.EdgeInsets.all(10),
//                   color: PdfColors.grey300,
//                   child: pw.Text(
//                     '${entry.key} Department (${entry.value.length} ${entry.value.length == 1 ? 'Employee' : 'Employees'})',
//                     style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Expanded(
//                   child: pw.ListView.builder(
//                     itemCount: entry.value.length,
//                     itemBuilder: (context, index) {
//                       final emp = entry.value[index];
//                       return pw.Container(
//                         margin: const pw.EdgeInsets.only(bottom: 15),
//                         padding: const pw.EdgeInsets.all(10),
//                         decoration: pw.BoxDecoration(
//                           border: pw.Border.all(color: PdfColors.grey400),
//                           borderRadius: pw.BorderRadius.circular(5),
//                         ),
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Row(
//                               mainAxisAlignment:
//                                   pw.MainAxisAlignment.spaceBetween,
//                               children: [
//                                 pw.Text(
//                                   emp.employeeName,
//                                   style: pw.TextStyle(
//                                     fontWeight: pw.FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 pw.Text(
//                                   'ID: ${emp.employeeId}',
//                                   style: const pw.TextStyle(fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                             pw.Divider(),
//                             _buildPdfInfoRow('Month', emp.month),
//                             _buildPdfInfoRow('Goals Met', '${emp.goalsMet}%'),
//                             _buildPdfInfoRow(
//                               'Tasks Completed',
//                               emp.tasksCompleted,
//                             ),
//                             if (emp.peerFeedback != null &&
//                                 emp.peerFeedback!.isNotEmpty)
//                               _buildPdfInfoRow(
//                                 'Peer Feedback',
//                                 emp.peerFeedback!,
//                               ),
//                             if (emp.managerComments != null &&
//                                 emp.managerComments!.isNotEmpty)
//                               _buildPdfInfoRow(
//                                 'Manager Comments',
//                                 emp.managerComments!,
//                               ),
//                             pw.SizedBox(height: 10),
//                             pw.Text(
//                               'Performance Summary:',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             pw.SizedBox(height: 5),
//                             pw.Container(
//                               width: double.infinity,
//                               padding: const pw.EdgeInsets.all(8),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColors.grey100,
//                                 borderRadius: pw.BorderRadius.circular(5),
//                               ),
//                               child: pw.Text(emp.summary),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }

//     // Show print/save dialog
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//       name: 'employee_performance_summaries.pdf',
//     );
//   }

//   static pw.Widget _buildPdfInfoRow(String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 2),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.SizedBox(
//             width: 120,
//             child: pw.Text(
//               '$label:',
//               style: pw.TextStyle(
//                 fontWeight: pw.FontWeight.bold,
//                 fontSize: 10,
//                 color: PdfColors.grey700,
//               ),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/employee_model.dart';

class PdfGenerator {
  static Future<void> generateAndSavePdf(
    BuildContext context,
    List<EmployeeData> employees,
  ) async {
    final pdf = pw.Document();

    // Group employees by department
    Map<String, List<EmployeeData>> departmentGroups = {};
    for (var emp in employees) {
      if (!departmentGroups.containsKey(emp.department)) {
        departmentGroups[emp.department] = [];
      }
      departmentGroups[emp.department]!.add(emp);
    }

    // Add title page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Employee Performance Summaries',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated on ${DateTime.now().toLocal().toString().split(' ')[0]}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Total Employees: ${employees.length}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Departments: ${departmentGroups.keys.join(', ')}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    // For each department, create a section header page
    for (var deptEntry in departmentGroups.entries) {
      final departmentName = deptEntry.key;
      final deptEmployees = deptEntry.value;

      // Add department header page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.grey300,
                  child: pw.Text(
                    '$departmentName Department',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Number of Employees: ${deptEmployees.length}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'The following pages contain performance summaries for all employees in this department.',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
      );

      // Now add INDIVIDUAL PAGES for EACH employee in this department
      for (var emp in deptEmployees) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Employee header
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    color: PdfColors.blue100,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          emp.employeeName,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        pw.Text(
                          'ID: ${emp.employeeId}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Employee details
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: _buildPdfInfoItem(
                                  'Department', departmentName),
                            ),
                            pw.Expanded(
                              child: _buildPdfInfoItem('Month', emp.month),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 15),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: _buildPdfInfoItem('Goals Met',
                                  '${emp.goalsMet.toStringAsFixed(1)}%'),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 15),
                        _buildPdfInfoItem(
                            'Tasks Completed', emp.tasksCompleted),
                        if (emp.peerFeedback != null &&
                            emp.peerFeedback!.isNotEmpty) ...[
                          pw.SizedBox(height: 15),
                          _buildPdfInfoItem('Peer Feedback', emp.peerFeedback!),
                        ],
                        if (emp.managerComments != null &&
                            emp.managerComments!.isNotEmpty) ...[
                          pw.SizedBox(height: 15),
                          _buildPdfInfoItem(
                              'Manager Comments', emp.managerComments!),
                        ],
                        pw.SizedBox(height: 20),
                        pw.Text(
                          'Performance Summary',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Text(
                            emp.summary,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  pw.Spacer(),
                  pw.Center(
                    child: pw.Text(
                      '$departmentName Department - ${emp.employeeName} - ${emp.employeeId}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    // Show print/save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'employee_performance_summaries.pdf',
    );
  }

  static pw.Widget _buildPdfInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
