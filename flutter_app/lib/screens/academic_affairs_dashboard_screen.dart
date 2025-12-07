import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/lecturer.dart';
import '../models/grade.dart';
import '../models/audit_log.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AcademicAffairsDashboardScreen extends StatefulWidget {
  const AcademicAffairsDashboardScreen({super.key});

  @override
  State<AcademicAffairsDashboardScreen> createState() => _AcademicAffairsDashboardScreenState();
}

class _AcademicAffairsDashboardScreenState extends State<AcademicAffairsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _statistics;
  List<Student> _students = [];
  List<Lecturer> _lecturers = [];
  List<Grade> _grades = [];
  List<AuditLog> _auditLogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
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

    try {
      // Load statistics
      final statsResponse = await apiService.getAcademicStatistics(token);
      if (statsResponse.success) {
        _statistics = statsResponse.data;
      }

      // Load students
      final studentsResponse = await apiService.getAcademicStudents(token);
      if (studentsResponse.success && studentsResponse.data != null) {
        _students = studentsResponse.data!;
      }

      // Load lecturers
      final lecturersResponse = await apiService.getAcademicLecturers(token);
      if (lecturersResponse.success && lecturersResponse.data != null) {
        _lecturers = lecturersResponse.data!;
      }

      // Load grades
      final gradesResponse = await apiService.getAcademicGrades(token);
      if (gradesResponse.success && gradesResponse.data != null) {
        _grades = gradesResponse.data!;
      }

      // Load audit logs
      final auditResponse = await apiService.getAuditLogs(token);
      if (auditResponse.success && auditResponse.data != null) {
        _auditLogs = auditResponse.data!;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditGradeDialog(Grade grade) async {
    final midtermController = TextEditingController(
      text: grade.midtermScore?.toString() ?? '',
    );
    final finalController = TextEditingController(
      text: grade.finalScore?.toString() ?? '',
    );
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Grade - ${grade.courseName ?? 'Course'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: midtermController,
              decoration: const InputDecoration(labelText: 'Midterm Score'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: finalController,
              decoration: const InputDecoration(labelText: 'Final Score'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Modification Reason',
                hintText: 'Required for audit',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result == true && grade.gradeId != null) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.token == null) return;
      final token = authService.token!;

      if (token != null) {
        final updatedGrade = Grade(
          gradeId: grade.gradeId,
          enrollmentId: grade.enrollmentId,
          midtermScore: double.tryParse(midtermController.text),
          finalScore: double.tryParse(finalController.text),
        );

        final apiService = ApiService();
        final response = await apiService.updateAcademicGrade(
          token,
          grade.gradeId!,
          updatedGrade,
          reasonController.text.isNotEmpty ? reasonController.text : null,
        );

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grade updated successfully')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.message}')),
          );
        }
      }
    }
  }

  Future<void> _approveGrade(Grade grade) async {
    if (grade.gradeId == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.token == null) return;
      final token = authService.token!;
      
    if (token != null) {
      final apiService = ApiService();
      final response = await apiService.approveGrade(token, grade.gradeId!);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade approved successfully')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Affairs Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.school), text: 'Lecturers'),
            Tab(icon: Icon(Icons.grade), text: 'Grades'),
            Tab(icon: Icon(Icons.history), text: 'Audit Logs'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildStudentsTab(),
                    _buildLecturersTab(),
                    _buildGradesTab(),
                    _buildAuditLogsTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 48),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Academic Affairs',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text('Full system access'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('System Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Students', _statistics?['totalStudents'] ?? 0, Icons.people, Colors.blue),
                _buildStatCard('Lecturers', _statistics?['totalLecturers'] ?? 0, Icons.school, Colors.green),
                _buildStatCard('Grades', _statistics?['totalGrades'] ?? 0, Icons.grade, Colors.orange),
                _buildStatCard('Faculties', _statistics?['totalFaculties'] ?? 0, Icons.business, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return _students.isEmpty
        ? const Center(child: Text('No students found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student.firstName?.substring(0, 1) ?? 'S'),
                  ),
                  title: Text(student.fullName),
                  subtitle: Text('ID: ${student.studentId ?? 'N/A'} • Class: ${student.classId ?? 'N/A'}'),
                  trailing: Chip(
                    label: Text(student.studentStatus ?? 'Active'),
                    backgroundColor: student.studentStatus == 'Active' ? Colors.green.shade100 : Colors.grey.shade100,
                  ),
                ),
              );
            },
          );
  }

  Widget _buildLecturersTab() {
    return _lecturers.isEmpty
        ? const Center(child: Text('No lecturers found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _lecturers.length,
            itemBuilder: (context, index) {
              final lecturer = _lecturers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      lecturer.firstName?.substring(0, 1) ?? 'L',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(lecturer.fullName),
                  subtitle: Text('${lecturer.academicDegree ?? ''} • ${lecturer.departmentId ?? 'N/A'}'),
                ),
              );
            },
          );
  }

  Widget _buildGradesTab() {
    return _grades.isEmpty
        ? const Center(child: Text('No grades found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _grades.length,
            itemBuilder: (context, index) {
              final grade = _grades[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getGradeColor(grade.letterGrade),
                    child: Text(
                      grade.letterGrade ?? '-',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(grade.courseName ?? 'Course'),
                  subtitle: Text(
                    'Total: ${grade.totalScore?.toStringAsFixed(1) ?? '-'} • Status: ${grade.gradeStatus ?? 'N/A'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (grade.gradeStatus != 'Approved')
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _approveGrade(grade),
                          tooltip: 'Approve',
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditGradeDialog(grade),
                        tooltip: 'Edit',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAuditLogsTab() {
    return _auditLogs.isEmpty
        ? const Center(child: Text('No audit logs found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _auditLogs.length,
            itemBuilder: (context, index) {
              final log = _auditLogs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getOperationColor(log.operation),
                    child: Icon(
                      _getOperationIcon(log.operation),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text('${log.tableName} - ${log.operationDisplay}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${log.username ?? log.userId ?? 'Unknown'}'),
                      Text(
                        log.operationDate?.toString() ?? 'Unknown date',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
  }

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  Color _getOperationColor(String? operation) {
    switch (operation) {
      case 'INSERT':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      case 'SELECT':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getOperationIcon(String? operation) {
    switch (operation) {
      case 'INSERT':
        return Icons.add;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      case 'SELECT':
        return Icons.visibility;
      default:
        return Icons.help;
    }
  }
}

