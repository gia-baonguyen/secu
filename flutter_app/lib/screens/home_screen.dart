import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'grades_screen.dart';
import 'gpa_screen.dart';
import 'lecturer_students_screen.dart';
import 'admin_students_screen.dart';
import 'admin_grades_screen.dart';

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
                      label: Text(user.role),
                      avatar: Icon(
                        user.role == 'STUDENT'
                            ? Icons.school
                            : user.role == 'LECTURER'
                                ? Icons.person
                                : Icons.admin_panel_settings,
                      ),
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
              // Only show student-specific actions for STUDENT role
              if (user?.role == 'STUDENT') ...[
                _buildActionCard(
                  context,
                  'View Grades',
                  Icons.grade,
                  Colors.blue,
                  () {
                    // Navigate to grades tab (index 1)
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
                _buildActionCard(
                  context,
                  'Check GPA',
                  Icons.calculate,
                  Colors.green,
                  () {
                    // Navigate to GPA tab (index 2)
                    if (onNavigate != null) onNavigate!(2);
                  },
                ),
              ],
              // Show role-specific actions for LECTURER
              if (user?.role == 'LECTURER') ...[
                _buildActionCard(
                  context,
                  'My Students',
                  Icons.people,
                  Colors.blue,
                  () {
                    // Navigate to students tab (index 1)
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
              ],
              // Show role-specific actions for ADMIN
              if (user?.role == 'ADMIN') ...[
                _buildActionCard(
                  context,
                  'All Students',
                  Icons.people,
                  Colors.blue,
                  () {
                    // Navigate to students tab (index 1)
                    if (onNavigate != null) onNavigate!(1);
                  },
                ),
                _buildActionCard(
                  context,
                  'All Grades',
                  Icons.grade,
                  Colors.green,
                  () {
                    // Navigate to grades tab (index 2)
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
                  // Navigate to profile tab (last tab)
                  // STUDENT: 4 tabs (0,1,2,3) -> Profile = 3
                  // LECTURER: 3 tabs (0,1,2) -> Profile = 2
                  // ADMIN: 4 tabs (0,1,2,3) -> Profile = 3
                  final profileIndex = user?.role == 'LECTURER' ? 2 : 3;
                  if (onNavigate != null) onNavigate!(profileIndex);
                },
              ),
              _buildActionCard(
                context,
                'Settings',
                Icons.settings,
                Colors.purple,
                () {
                  // Navigate to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings coming soon'),
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

