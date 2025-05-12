import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../services/employee_provider.dart';
import '../widgets/feature_card.dart';
import 'results_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String _selectedFileName = '';
  List<int>? _selectedFileBytes;
  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        const SnackBar(
          content: Text('Please select a CSV file first'),
          behavior: SnackBarBehavior.floating,
        ),
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

    _animationController.repeat();
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
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.reset();
      employeeProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Performance Summary'),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                tooltip: 'Analytics',
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
                icon: const Icon(Icons.info_outline),
                tooltip: 'About',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'About This App',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'This app uses AI to generate performance summaries from employee data. Upload a CSV file to get started.',
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Employee Performance',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate AI-powered summaries from employee data',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Feature cards
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      FeatureCard(
                        icon: Icons.upload_file,
                        title: 'Upload Data',
                        description:
                            'Import employee performance data using CSV files',
                        color: Colors.blue,
                      ),
                      FeatureCard(
                        icon: Icons.auto_awesome,
                        title: 'AI Summary',
                        description:
                            'Generate natural language performance reviews',
                        color: Colors.purple,
                      ),
                      FeatureCard(
                        icon: Icons.analytics,
                        title: 'Analytics',
                        description: 'View performance metrics and insights',
                        color: Colors.green,
                      ),
                      FeatureCard(
                        icon: Icons.picture_as_pdf,
                        title: 'Export',
                        description: 'Export summaries as PDF reports',
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Upload section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Upload CSV Data',
                                style: textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Upload a CSV file with employee performance data to generate natural language summaries for performance reviews.',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),

                          // File selection
                          GestureDetector(
                            onTap: _isLoading ? null : _pickCSVFile,
                            child: CustomPaint(
                              painter: DashedBorderPainter(
                                color: _selectedFileName.isEmpty
                                    ? colorScheme.outline
                                    : colorScheme.primary,
                                strokeWidth: 2,
                                dashPattern: [6, 3],
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: _selectedFileName.isEmpty
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload_file,
                                              size: 40,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Click to select a CSV file',
                                              style:
                                                  textTheme.bodyLarge?.copyWith(
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.description,
                                              size: 32,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Selected: $_selectedFileName',
                                              style:
                                                  textTheme.bodyLarge?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Click to change file',
                                              style: textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Generate button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _generateSummaries,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                disabledBackgroundColor:
                                    colorScheme.primary.withOpacity(0.6),
                                disabledForegroundColor:
                                    colorScheme.onPrimary.withOpacity(0.8),
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: colorScheme.onPrimary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text('Generating Summaries...'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.psychology,
                                          color: colorScheme.onPrimary,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Generate AI Summaries',
                                          style:
                                              textTheme.titleMedium?.copyWith(
                                            color: colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          if (_isLoading) ...[
                            const SizedBox(height: 16),
                            const LinearProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              'This may take a moment as the AI analyzes the data...',
                              style: textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Error',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Troubleshooting:',
                                    style: textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('• Check if the server is running'),
                                  Text('• Verify your CSV format'),
                                  Text(
                                    '• Ensure all required columns are present',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CSV Format Reference
                  Text('CSV Format Reference', style: textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Required CSV Column Headers:',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const SelectableText(
                          'employee_name,employee_id,department,month,tasks_completed,goals_met,peer_feedback,manager_comments',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Example Data Row:', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const SelectableText(
                          'John Smith,E001,Engineering,April 2025,"Completed API integration, Fixed bugs",92,"Great team player","Excellent problem solver"',
                          style: TextStyle(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to create a dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashPattern = const [3, 1],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    final Path dashPath = Path();
    final double dashLength = dashPattern[0];
    final double dashSpace = dashPattern[1];

    if (dashLength > 0 && dashSpace > 0) {
      final PathMetrics metrics = path.computeMetrics();
      for (final PathMetric metric in metrics) {
        double distance = 0.0;
        bool draw = true;
        while (distance < metric.length) {
          final double length = draw ? dashLength : dashSpace;
          if (draw) {
            dashPath.addPath(
              metric.extractPath(distance, distance + length),
              Offset.zero,
            );
          }
          distance += length;
          draw = !draw;
        }
      }
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern;
  }
}
