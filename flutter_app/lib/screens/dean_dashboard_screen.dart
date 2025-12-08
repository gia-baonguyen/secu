import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/lecturer.dart';
import '../models/grade.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DeanDashboardScreen extends StatefulWidget {
  const DeanDashboardScreen({super.key});

  @override
  State<DeanDashboardScreen> createState() => _DeanDashboardScreenState();
}

class _DeanDashboardScreenState extends State<DeanDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _facultyInfo;
  Map<String, dynamic>? _statistics;
  List<Student> _students = [];
  List<Lecturer> _lecturers = [];
  List<Grade> _grades = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      // Load faculty info
      final facultyResponse = await apiService.getDeanFacultyInfo(token);
      if (facultyResponse.success) {
        _facultyInfo = facultyResponse.data;
      }

      // Load statistics
      final statsResponse = await apiService.getDeanStatistics(token);
      if (statsResponse.success) {
        _statistics = statsResponse.data;
      }

      // Load students
      final studentsResponse = await apiService.getDeanStudents(token);
      if (studentsResponse.success && studentsResponse.data != null) {
        _students = studentsResponse.data!;
      }

      // Load lecturers
      final lecturersResponse = await apiService.getDeanLecturers(token);
      if (lecturersResponse.success && lecturersResponse.data != null) {
        _lecturers = lecturersResponse.data!;
      }

      // Load grades
      final gradesResponse = await apiService.getDeanGrades(token);
      if (gradesResponse.success && gradesResponse.data != null) {
        _grades = gradesResponse.data!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dean Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.school), text: 'Lecturers'),
            Tab(icon: Icon(Icons.grade), text: 'Grades'),
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
            // Faculty Info Card
            if (_facultyInfo != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _facultyInfo!['FACULTY_NAME'] ?? 'Faculty',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Dean: ${_facultyInfo!['DEAN_NAME'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Statistics Cards
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Students', _statistics?['totalStudents'] ?? 0, Icons.people, Colors.blue),
                _buildStatCard('Lecturers', _statistics?['totalLecturers'] ?? 0, Icons.school, Colors.green),
                _buildStatCard('Grades', _statistics?['totalGrades'] ?? 0, Icons.grade, Colors.orange),
                _buildStatCard('Departments', _statistics?['departments'] ?? 0, Icons.business, Colors.purple),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
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
                  subtitle: Text('${lecturer.academicDegree ?? ''} • ${lecturer.specialization ?? 'N/A'}'),
                  trailing: Text(lecturer.departmentId ?? ''),
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
                    'Midterm: ${grade.midtermScore?.toStringAsFixed(1) ?? '-'} • '
                    'Final: ${grade.finalScore?.toStringAsFixed(1) ?? '-'} • '
                    'Total: ${grade.totalScore?.toStringAsFixed(1) ?? '-'}',
                  ),
                  trailing: Chip(
                    label: Text(grade.gradeStatus ?? 'Pending'),
                    backgroundColor: grade.gradeStatus == 'Approved' ? Colors.green.shade100 : Colors.orange.shade100,
                  ),
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
}

