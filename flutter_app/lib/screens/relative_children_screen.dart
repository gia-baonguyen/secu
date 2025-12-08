import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Screen for relatives to view their linked children
/// 
/// SECURITY POLICY:
/// - Relatives can ONLY view GRADES
/// - Student personal info (names) is HIDDEN for privacy
/// - Only student_id and class_id are visible
class RelativeChildrenScreen extends StatefulWidget {
  const RelativeChildrenScreen({super.key});

  @override
  State<RelativeChildrenScreen> createState() => _RelativeChildrenScreenState();
}

class _RelativeChildrenScreenState extends State<RelativeChildrenScreen> {
  List<Student> _children = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.token == null) return;
    final token = authService.token!;

    if (token == null) {
      setState(() {
        _errorMessage = 'Not authenticated';
        _isLoading = false;
      });
      return;
    }

    final apiService = ApiService();
    final response = await apiService.getRelativeChildren(token);

    if (response.success && response.data != null) {
      setState(() {
        _children = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Failed to load children';
        _isLoading = false;
      });
    }
  }

  void _showChildGrades(Student child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildGradesScreen(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildren,
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
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChildren,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _children.isEmpty
                  ? const Center(child: Text('No children linked to your account'))
                  : RefreshIndicator(
                      onRefresh: _loadChildren,
                      child: Column(
                        children: [
                          // Privacy notice banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.privacy_tip, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Vì lý do bảo mật, thông tin cá nhân sinh viên được ẩn. Bạn chỉ có thể xem điểm.',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Children list
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _children.length,
                              itemBuilder: (context, index) {
                                final child = _children[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      child: const Icon(
                                        Icons.school,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // Only show student_id, NOT name (privacy policy)
                                    title: Text(
                                      'Sinh viên: ${child.studentId ?? 'N/A'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.class_, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text('Lớp: ${child.classId ?? 'N/A'}'),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              child.studentStatus == 'ACTIVE' 
                                                  ? Icons.check_circle 
                                                  : Icons.cancel,
                                              size: 14,
                                              color: child.studentStatus == 'ACTIVE' 
                                                  ? Colors.green 
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              child.studentStatus ?? 'N/A',
                                              style: TextStyle(
                                                color: child.studentStatus == 'ACTIVE' 
                                                    ? Colors.green 
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Xem điểm',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () => _showChildGrades(child),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

/// Screen to display grades for a specific child
/// 
/// SECURITY: Only shows grades, student name is hidden
class ChildGradesScreen extends StatefulWidget {
  final Student child;

  const ChildGradesScreen({super.key, required this.child});

  @override
  State<ChildGradesScreen> createState() => _ChildGradesScreenState();
}

class _ChildGradesScreenState extends State<ChildGradesScreen> {
  List<Grade> _grades = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.token == null) return;
    final token = authService.token!;

    if (token == null || widget.child.studentId == null) {
      setState(() {
        _errorMessage = 'Invalid data';
        _isLoading = false;
      });
      return;
    }

    final apiService = ApiService();
    final response = await apiService.getChildGrades(token, widget.child.studentId!);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show student_id instead of name (privacy policy)
        title: Text('Điểm - ${widget.child.studentId ?? 'N/A'}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _grades.isEmpty
                  ? const Center(child: Text('No grades available'))
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
                                  Text(
                                    grade.courseName ?? 'Course ${index + 1}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildScoreColumn('Midterm', grade.midtermScore),
                                      _buildScoreColumn('Final', grade.finalScore),
                                      _buildScoreColumn('Total', grade.totalScore),
                                      _buildGradeColumn(grade.letterGrade),
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

  Widget _buildScoreColumn(String label, double? score) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          score?.toStringAsFixed(1) ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGradeColumn(String? letterGrade) {
    Color gradeColor;
    switch (letterGrade) {
      case 'A':
        gradeColor = Colors.green;
        break;
      case 'B':
        gradeColor = Colors.blue;
        break;
      case 'C':
        gradeColor = Colors.orange;
        break;
      case 'D':
        gradeColor = Colors.deepOrange;
        break;
      default:
        gradeColor = Colors.red;
    }

    return Column(
      children: [
        const Text('Grade', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: gradeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: gradeColor),
          ),
          child: Text(
            letterGrade ?? '-',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: gradeColor,
            ),
          ),
        ),
      ],
    );
  }
}

