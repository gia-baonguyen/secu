import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecturer.dart';
import '../models/course.dart';
import '../models/grade.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DepartmentHeadDashboardScreen extends StatefulWidget {
  const DepartmentHeadDashboardScreen({super.key});

  @override
  State<DepartmentHeadDashboardScreen> createState() => _DepartmentHeadDashboardScreenState();
}

class _DepartmentHeadDashboardScreenState extends State<DepartmentHeadDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _departmentInfo;
  Map<String, dynamic>? _statistics;
  List<Lecturer> _lecturers = [];
  List<Course> _courses = [];
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
      // Load department info
      final deptResponse = await apiService.getDepartmentInfo(token);
      if (deptResponse.success) {
        _departmentInfo = deptResponse.data;
      }

      // Load statistics
      final statsResponse = await apiService.getDepartmentStatistics(token);
      if (statsResponse.success) {
        _statistics = statsResponse.data;
      }

      // Load lecturers
      final lecturersResponse = await apiService.getDepartmentLecturers(token);
      if (lecturersResponse.success && lecturersResponse.data != null) {
        _lecturers = lecturersResponse.data!;
      }

      // Load courses
      final coursesResponse = await apiService.getDepartmentCourses(token);
      if (coursesResponse.success && coursesResponse.data != null) {
        _courses = coursesResponse.data!;
      }

      // Load grades
      final gradesResponse = await apiService.getDepartmentGrades(token);
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
        title: const Text('Department Head Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.school), text: 'Lecturers'),
            Tab(icon: Icon(Icons.book), text: 'Courses'),
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
                    _buildLecturersTab(),
                    _buildCoursesTab(),
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
            // Department Info Card
            if (_departmentInfo != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _departmentInfo!['DEPARTMENT_NAME'] ?? 'Department',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Faculty: ${_departmentInfo!['FACULTY_NAME'] ?? 'N/A'}'),
                      Text('Head: ${_departmentInfo!['HEAD_NAME'] ?? 'N/A'}'),
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
              childAspectRatio: 2.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Lecturers', _statistics?['totalLecturers'] ?? 0, Icons.school, Colors.green),
                _buildStatCard('Courses', _statistics?['totalCourses'] ?? 0, Icons.book, Colors.blue),
                _buildStatCard('Grades', _statistics?['totalGrades'] ?? 0, Icons.grade, Colors.orange),
                _buildStatCard('Students', _statistics?['totalStudents'] ?? 0, Icons.people, Colors.purple),
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
                  trailing: Chip(
                    label: Text(lecturer.lecturerStatus ?? 'Active'),
                    backgroundColor: lecturer.lecturerStatus == 'Active' ? Colors.green.shade100 : Colors.grey.shade100,
                  ),
                ),
              );
            },
          );
  }

  Widget _buildCoursesTab() {
    return _courses.isEmpty
        ? const Center(child: Text('No courses found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${course.credits ?? 0}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(course.courseName ?? 'Course'),
                  subtitle: Text('ID: ${course.courseId ?? 'N/A'} • ${course.courseType ?? 'N/A'}'),
                  trailing: course.hasPrerequisite
                      ? const Chip(label: Text('Has Prereq'), backgroundColor: Colors.orange)
                      : null,
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

