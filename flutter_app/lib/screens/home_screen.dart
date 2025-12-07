import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'grades_screen.dart';
import 'gpa_screen.dart';
import 'lecturer_students_screen.dart';
import 'admin_students_screen.dart';
import 'admin_grades_screen.dart';
import 'exam_questions_screen.dart';
import 'relative_children_screen.dart';
import 'dean_dashboard_screen.dart';
import 'department_head_dashboard_screen.dart';
import 'academic_affairs_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    // Build screens based on user role
    final List<Widget> screens;
    final List<NavigationDestination> destinations;

    if (user?.role == 'STUDENT') {
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const GradesScreen(),
        const GpaScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.grade_outlined),
          selectedIcon: Icon(Icons.grade),
          label: 'Grades',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate),
          label: 'GPA',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (user?.role == 'LECTURER') {
      // For Lecturer: Home, My Students, Profile (Grades removed - view grades by clicking on student)
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const LecturerStudentsScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Students',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (user?.role == 'RELATIVE') {
      // For Relative: Home, My Children, Profile
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const RelativeChildrenScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom),
          label: 'Children',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (user?.role == 'DEAN') {
      // For Dean: Home, Dashboard, Profile
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const DeanDashboardScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (user?.role == 'DEPARTMENT_HEAD') {
      // For Department Head: Home, Dashboard, Profile
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const DepartmentHeadDashboardScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (user?.role == 'ACADEMIC_AFFAIRS') {
      // For Academic Affairs: Home, Dashboard, Profile
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const AcademicAffairsDashboardScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // For Admin: Home, All Students, All Grades, Profile
      screens = [
        HomeTab(onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const AdminStudentsScreen(),
        const AdminGradesScreen(),
        const ProfileScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Students',
        ),
        NavigationDestination(
          icon: Icon(Icons.grade_outlined),
          selectedIcon: Icon(Icons.grade),
          label: 'Grades',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // Reset index if it's out of bounds
    if (_currentIndex >= screens.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: screens[_currentIndex.clamp(0, screens.length - 1)],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex.clamp(0, destinations.length - 1),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final Function(int)? onNavigate;
  
  const HomeTab({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (user != null) ...[
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(_getRoleDisplayName(user.role)),
                      avatar: Icon(_getRoleIcon(user.role)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              // STUDENT actions
              if (user?.role == 'STUDENT') ...[
                _buildActionCard(
                  context,
                  'View Grades',
                  Icons.grade,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
                _buildActionCard(
                  context,
                  'Check GPA',
                  Icons.calculate,
                  Colors.green,
                  () {
                    if (onNavigate != null) onNavigate!(2);
                  },
                ),
              ],
              // LECTURER actions
              if (user?.role == 'LECTURER') ...[
                _buildActionCard(
                  context,
                  'My Students',
                  Icons.people,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
              ],
              // RELATIVE actions
              if (user?.role == 'RELATIVE') ...[
                _buildActionCard(
                  context,
                  'My Children',
                  Icons.family_restroom,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
              ],
              // DEAN actions
              if (user?.role == 'DEAN') ...[
                _buildActionCard(
                  context,
                  'Faculty Dashboard',
                  Icons.dashboard,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
              ],
              // DEPARTMENT_HEAD actions
              if (user?.role == 'DEPARTMENT_HEAD') ...[
                _buildActionCard(
                  context,
                  'Department Dashboard',
                  Icons.dashboard,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
              ],
              // ACADEMIC_AFFAIRS actions
              if (user?.role == 'ACADEMIC_AFFAIRS') ...[
                _buildActionCard(
                  context,
                  'System Dashboard',
                  Icons.admin_panel_settings,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
              ],
              // ADMIN actions
              if (user?.role == 'ADMIN') ...[
                _buildActionCard(
                  context,
                  'All Students',
                  Icons.people,
                  Colors.blue,
                  () {
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
                _buildActionCard(
                  context,
                  'All Grades',
                  Icons.grade,
                  Colors.green,
                  () {
                    if (onNavigate != null) onNavigate!(2);
                  },
                ),
              ],
              // Common actions
              _buildActionCard(
                context,
                'My Profile',
                Icons.person,
                Colors.orange,
                () {
                  // Profile is the last tab for all roles
                  final profileIndex = _getProfileIndex(user?.role);
                  if (onNavigate != null) onNavigate!(profileIndex);
                },
              ),
              // Exam Questions - OLS protected (available to all roles, filtered by OLS)
              _buildActionCard(
                context,
                'Exam Questions',
                Icons.quiz,
                Colors.teal,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExamQuestionsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getProfileIndex(String? role) {
    switch (role) {
      case 'STUDENT':
        return 3; // Home, Grades, GPA, Profile
      case 'LECTURER':
      case 'RELATIVE':
      case 'DEAN':
      case 'DEPARTMENT_HEAD':
      case 'ACADEMIC_AFFAIRS':
        return 2; // Home, Dashboard/Students, Profile
      case 'ADMIN':
        return 3; // Home, Students, Grades, Profile
      default:
        return 2;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'STUDENT':
        return 'Student';
      case 'LECTURER':
        return 'Lecturer';
      case 'RELATIVE':
        return 'Parent/Guardian';
      case 'DEAN':
        return 'Dean';
      case 'DEPARTMENT_HEAD':
        return 'Department Head';
      case 'ACADEMIC_AFFAIRS':
        return 'Academic Affairs';
      case 'ADMIN':
        return 'Administrator';
      default:
        return role;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'STUDENT':
        return Icons.school;
      case 'LECTURER':
        return Icons.person;
      case 'RELATIVE':
        return Icons.family_restroom;
      case 'DEAN':
        return Icons.account_balance;
      case 'DEPARTMENT_HEAD':
        return Icons.business;
      case 'ACADEMIC_AFFAIRS':
        return Icons.admin_panel_settings;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
