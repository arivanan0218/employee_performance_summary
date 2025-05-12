import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/employee_provider.dart';
import 'results_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  String _selectedFileName = '';
  List<int>? _selectedFileBytes;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
        _errorMessage = ''; // Clear any previous errors
      });

      // Print the first 200 bytes to check the file content
      if (_selectedFileBytes != null && _selectedFileBytes!.isNotEmpty) {
        print('CSV file selected: $_selectedFileName');
        final previewBytes = _selectedFileBytes!.take(200).toList();
        print('First 200 bytes: $previewBytes');

        // Try to decode the first 200 bytes as utf8 to verify it's a valid CSV
        try {
          final preview = String.fromCharCodes(previewBytes);
          print('CSV preview: $preview');
        } catch (e) {
          print('Error decoding CSV preview: $e');
        }
      }
    }
  }

  Future<void> _generateSummaries() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a CSV file first')),
      );
      return;
    }

    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    employeeProvider.setLoading(true);
    employeeProvider.setError('');

    try {
      final summaries = await _apiService.uploadCsvFile(
        _selectedFileBytes!,
        _selectedFileName,
      );

      // Print out the data we got back for verification
      print('Received ${summaries.length} employee summaries:');
      for (var emp in summaries) {
        print(
          '${emp.employeeName} - Goals Met: ${emp.goalsMet}%, Tasks: ${emp.tasksCompleted}',
        );
      }

      employeeProvider.setEmployees(summaries);

      // Navigate to results screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultsScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      employeeProvider.setError(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      employeeProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Performance Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.assessment_outlined,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Generate AI-Powered Performance Summaries',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload a CSV file with employee performance data to generate natural language summaries for performance reviews.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Select CSV File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onPressed: _isLoading ? null : _pickCSVFile,
              ),
              const SizedBox(height: 20),
              if (_selectedFileName.isNotEmpty)
                Text(
                  'Selected file: $_selectedFileName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Icon(Icons.psychology_alt),
                label: Text(
                  _isLoading ? 'Generating...' : 'Generate Summaries',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                onPressed: _isLoading ? null : _generateSummaries,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                Column(
                  children: [
                    LinearProgressIndicator(),
                    const SizedBox(height: 10),
                    const Text(
                      'This may take a few moments as the AI generates summaries...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),

              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Error:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(_errorMessage),
                      const SizedBox(height: 10),
                      const Text(
                        'Troubleshooting Steps:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text('1. Make sure the FastAPI server is running'),
                      const Text(
                        '2. Check your CSV file format (see example below)',
                      ),
                      const Text(
                        '3. Verify the server address in your API service',
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CSV Example: employee_name,employee_id,department,month,tasks_completed,goals_met',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
