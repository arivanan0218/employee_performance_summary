import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/employee_model.dart';

class ApiService {
  // Choose the appropriate baseUrl based on where you're running
  final String baseUrl =
      // For web or test on same machine
      kIsWeb
          ? 'http://localhost:8000'
          :
          // For Android emulator
          'http://10.0.2.2:8000';
  // Uncomment the line below and replace with your computer's IP address if using a physical device
  // 'http://192.168.1.X:8000'; // Replace X with your actual IP

  Future<List<EmployeeData>> uploadCsvFile(
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      print('Attempting to connect to: $baseUrl/upload-csv/');

      final uri = Uri.parse('$baseUrl/upload-csv/');

      // Set timeout to 30 seconds
      var request = http.MultipartRequest('POST', uri);

      // Add the file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType('text', 'csv'),
        ),
      );

      // Send the request with timeout
      print('Sending request...');
      final httpClient = http.Client();
      try {
        // Send the request
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60), // Extended timeout for larger files
          onTimeout: () {
            throw Exception(
              'Connection timed out. Please check if the server is running and accessible.',
            );
          },
        );

        print('Response status code: ${streamedResponse.statusCode}');
        final responseBody = await streamedResponse.stream.bytesToString();

        // Debug response
        print(
          'Raw response body (first 500 chars): ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}...',
        );

        if (streamedResponse.statusCode == 200) {
          print('Successfully received response');

          try {
            // Decode the JSON response
            final jsonResponse = json.decode(responseBody);
            print('JSON response type: ${jsonResponse.runtimeType}');

            if (jsonResponse is List) {
              print('Response contains ${jsonResponse.length} items');

              // Log complete structure of first item for debugging
              if (jsonResponse.isNotEmpty) {
                print(
                  'First item complete structure: ${json.encode(jsonResponse[0])}',
                );
              }

              // Loop through each item and create employee objects
              List<EmployeeData> employees = [];
              for (int i = 0; i < jsonResponse.length; i++) {
                final item = jsonResponse[i];
                print(
                  'Processing item $i: employee_name=${item['employee_name']}, goals_met=${item['goals_met']}, tasks_completed=${item['tasks_completed']}',
                );

                try {
                  final employee = EmployeeData.fromJson(item);
                  print(
                    'Successfully parsed employee ${employee.employeeName} with goals_met=${employee.goalsMet} and tasks=${employee.tasksCompleted}',
                  );
                  employees.add(employee);
                } catch (e) {
                  print('Error parsing item $i: $e');
                  // Add a placeholder employee if there's an error
                  employees.add(
                    EmployeeData(
                      employeeName:
                          item['employee_name']?.toString() ?? 'Error',
                      employeeId: item['employee_id']?.toString() ?? 'Error',
                      department: item['department']?.toString() ?? 'Error',
                      month: item['month']?.toString() ?? 'Error',
                      tasksCompleted: 'Error parsing data',
                      goalsMet: 0.0,
                      summary:
                          'Error parsing this employee data: ${e.toString()}',
                    ),
                  );
                }
              }
              return employees;
            } else {
              print('Response is not a list: $jsonResponse');
              throw Exception(
                'Unexpected response format: Expected a list but got ${jsonResponse.runtimeType}',
              );
            }
          } catch (e) {
            print('Error parsing JSON: $e');
            print('Raw response: $responseBody');
            throw Exception('Error parsing response: $e');
          }
        } else {
          print(
            'Error response: ${streamedResponse.statusCode} - $responseBody',
          );
          throw Exception(
            'Failed to upload CSV: ${streamedResponse.statusCode} - $responseBody',
          );
        }
      } finally {
        httpClient.close();
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error uploading CSV: $e');
    }
  }
}
