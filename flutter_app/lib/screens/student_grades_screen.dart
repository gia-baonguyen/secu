import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/grade.dart';
import '../models/student.dart';

class StudentGradesScreen extends StatefulWidget {
  final Student student;

  const StudentGradesScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  List<Grade> _grades = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final authService = context.read<AuthService>();
    if (authService.token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.getLecturerStudentGrades(
        authService.token!,
        widget.student.studentId,
      );

      if (response.success && response.data != null) {
        setState(() {
          _grades = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load grades';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.fullName} - Grades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGrades,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGrades,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _grades.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grade_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No grades found for this student',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadGrades,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _grades.length,
                        itemBuilder: (context, index) {
                          final grade = _grades[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          grade.courseName ?? 'Môn học ${index + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      // Update button for Lecturer
                                      if (context.read<AuthService>().currentUser?.role == 'LECTURER')
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showUpdateGradeDialog(context, grade),
                                          tooltip: 'Update Grade',
                                        ),
                                      if (grade.letterGrade != null)
                                        Chip(
                                          label: Text(
                                            grade.letterGrade!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: _getGradeColor(grade.letterGrade!)
                                              .withOpacity(0.2),
                                        ),
                                    ],
                                  ),
                                  if (grade.gradeStatus != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Status: ${grade.gradeStatus}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildScoreItem('Midterm', grade.midtermScore),
                                      ),
                                      Expanded(
                                        child: _buildScoreItem('Final', grade.finalScore),
                                      ),
                                      Expanded(
                                        child: _buildScoreItem('Total', grade.totalScore, isTotal: true),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildScoreItem(String label, double? score, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score != null ? score.toStringAsFixed(1) : 'N/A',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String letterGrade) {
    switch (letterGrade.toUpperCase()) {
      case 'A':
      case 'A+':
        return Colors.green;
      case 'B':
      case 'B+':
        return Colors.blue;
      case 'C':
      case 'C+':
        return Colors.orange;
      case 'D':
        return Colors.orange[700]!;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateGradeDialog(BuildContext context, Grade grade) {
    final midtermController = TextEditingController(
      text: grade.midtermScore?.toStringAsFixed(1) ?? '',
    );
    final finalController = TextEditingController(
      text: grade.finalScore?.toStringAsFixed(1) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Grade - ${grade.courseName ?? "Course"}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: midtermController,
              decoration: const InputDecoration(
                labelText: 'Midterm Score',
                hintText: 'Enter midterm score (0-10)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: finalController,
              decoration: const InputDecoration(
                labelText: 'Final Score',
                hintText: 'Enter final score (0-10)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final midterm = double.tryParse(midtermController.text);
              final finalScore = double.tryParse(finalController.text);

              if (midterm == null || finalScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid scores')),
                );
                return;
              }

              if (midterm < 0 || midterm > 10 || finalScore < 0 || finalScore > 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scores must be between 0 and 10')),
                );
                return;
              }

              await _updateGrade(context, grade, midterm, finalScore);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateGrade(BuildContext context, Grade grade, double midterm, double finalScore) async {
    final authService = context.read<AuthService>();
    if (authService.token == null || grade.gradeId == null) return;

    try {
      final apiService = ApiService();
      final updatedGrade = grade.copyWith(
        midtermScore: midterm,
        finalScore: finalScore,
      );

      final response = await apiService.updateGrade(
        authService.token!,
        grade.gradeId!,
        updatedGrade,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade updated successfully')),
        );
        _loadGrades();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to update grade')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

