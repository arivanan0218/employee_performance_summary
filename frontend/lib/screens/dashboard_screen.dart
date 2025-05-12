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

  Future<void> _pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
      });
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
    employeeProvider.setLoading(true);
    employeeProvider.setError('');

    try {
      final summaries = await _apiService.uploadCsvFile(
        _selectedFileBytes!,
        _selectedFileName,
      );
      employeeProvider.setEmployees(summaries);

      // Navigate to results screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultsScreen()),
        );
      }
    } catch (e) {
      employeeProvider.setError(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      employeeProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<EmployeeProvider>(context).isLoading;

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
                onPressed: isLoading ? null : _pickCSVFile,
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
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Icon(Icons.psychology_alt),
                label: Text(isLoading ? 'Generating...' : 'Generate Summaries'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                onPressed: isLoading ? null : _generateSummaries,
              ),
              const SizedBox(height: 20),
              if (isLoading) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
