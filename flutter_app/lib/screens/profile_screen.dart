import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/student.dart';
import '../models/lecturer.dart';
import '../models/relative.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Student? _student;
  Lecturer? _lecturer;
  Relative? _relative;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authService = context.read<AuthService>();
    if (authService.token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Load profile based on role
    if (authService.currentUser?.role == 'STUDENT') {
      await _loadStudentProfile(authService.token!);
    } else if (authService.currentUser?.role == 'LECTURER') {
      await _loadLecturerProfile(authService.token!);
    } else if (authService.currentUser?.role == 'RELATIVE') {
      await _loadRelativeProfile(authService.token!);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = null; // No error, just not applicable
      });
      return;
    }
  }

  Future<void> _loadStudentProfile(String token) async {
    try {
      final apiService = ApiService();
      final response = await apiService.getStudentProfile(token);

      if (response.success && response.data != null) {
        setState(() {
          _student = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load profile';
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

  Future<void> _loadLecturerProfile(String token) async {
    try {
      final apiService = ApiService();
      final response = await apiService.getLecturerProfile(token);

      if (response.success && response.data != null) {
        setState(() {
          _lecturer = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load profile';
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

  Future<void> _loadRelativeProfile(String token) async {
    try {
      final apiService = ApiService();
      final response = await apiService.getRelativeProfile(token);

      if (response.success && response.data != null) {
        setState(() {
          _relative = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load profile';
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
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
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
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                  user?.username.substring(0, 1).toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _student?.fullName ?? _lecturer?.fullName ?? _relative?.fullName ?? user?.username ?? 'User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (user != null) ...[
                                const SizedBox(height: 8),
                                Chip(
                                  label: Text(user.role),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Update Profile Button (for Student, Lecturer, and Relative)
                      if (user?.role == 'STUDENT' || user?.role == 'LECTURER' || user?.role == 'RELATIVE')
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showUpdateProfileDialog(context),
                                icon: const Icon(Icons.edit),
                                label: const Text('Update Profile'),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // User info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Divider(),
                              _buildInfoRow('User ID', user?.userId ?? 'N/A'),
                              _buildInfoRow('Username', user?.username ?? 'N/A'),
                              if (user?.email != null)
                                _buildInfoRow('Email', user!.email!),
                              if (user != null)
                                _buildInfoRow('Role', user.role),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Student info
                      if (_student != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student Information',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Divider(),
                                _buildInfoRow(
                                    'Student ID', _student!.studentId),
                                if (_student!.firstName != null)
                                  _buildInfoRow(
                                      'First Name', _student!.firstName!),
                                if (_student!.lastName != null)
                                  _buildInfoRow(
                                      'Last Name', _student!.lastName!),
                                if (_student!.email != null)
                                  _buildInfoRow('Email', _student!.email!),
                                if (_student!.phoneNumber != null)
                                  _buildInfoRow(
                                      'Phone', _student!.phoneNumber!),
                                if (_student!.classId != null)
                                  _buildInfoRow('Class', _student!.classId!),
                              ],
                            ),
                          ),
                        ),

                      // Lecturer info
                      if (_lecturer != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lecturer Information',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Divider(),
                                _buildInfoRow(
                                    'Lecturer ID', _lecturer!.lecturerId),
                                if (_lecturer!.firstName != null)
                                  _buildInfoRow(
                                      'First Name', _lecturer!.firstName!),
                                if (_lecturer!.lastName != null)
                                  _buildInfoRow(
                                      'Last Name', _lecturer!.lastName!),
                                if (_lecturer!.email != null)
                                  _buildInfoRow('Email', _lecturer!.email!),
                                if (_lecturer!.phoneNumber != null)
                                  _buildInfoRow(
                                      'Phone', _lecturer!.phoneNumber!),
                                if (_lecturer!.departmentId != null)
                                  _buildInfoRow(
                                      'Department', _lecturer!.departmentId!),
                              ],
                            ),
                          ),
                        ),

                      // Relative info
                      if (_relative != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Relative Information',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Divider(),
                                _buildInfoRow(
                                    'Relative ID', _relative!.relativeId ?? 'N/A'),
                                if (_relative!.firstName != null)
                                  _buildInfoRow(
                                      'First Name', _relative!.firstName!),
                                if (_relative!.lastName != null)
                                  _buildInfoRow(
                                      'Last Name', _relative!.lastName!),
                                if (_relative!.email != null)
                                  _buildInfoRow('Email', _relative!.email!),
                                if (_relative!.phoneNumber != null)
                                  _buildInfoRow(
                                      'Phone', _relative!.phoneNumber!),
                                if (_relative!.contactAddress != null)
                                  _buildInfoRow(
                                      'Address', _relative!.contactAddress!),
                                if (_relative!.occupation != null)
                                  _buildInfoRow(
                                      'Occupation', _relative!.occupation!),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user?.role == 'STUDENT' && _student != null) {
      _showUpdateStudentDialog(context);
    } else if (user?.role == 'LECTURER' && _lecturer != null) {
      _showUpdateLecturerDialog(context);
    } else if (user?.role == 'RELATIVE' && _relative != null) {
      _showUpdateRelativeDialog(context);
    }
  }

  void _showUpdateStudentDialog(BuildContext context) {
    final emailController = TextEditingController(text: _student?.email ?? '');
    final phoneController = TextEditingController(text: _student?.phoneNumber ?? '');
    final addressController = TextEditingController(text: _student?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
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
              final updatedStudent = _student!.copyWith(
                email: emailController.text.isEmpty ? null : emailController.text,
                phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                address: addressController.text.isEmpty ? null : addressController.text,
              );

              await _updateStudentProfile(context, updatedStudent);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateLecturerDialog(BuildContext context) {
    final emailController = TextEditingController(text: _lecturer?.email ?? '');
    final phoneController = TextEditingController(text: _lecturer?.phoneNumber ?? '');
    final addressController = TextEditingController(text: _lecturer?.contactAddress ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
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
              final updatedLecturer = _lecturer!.copyWith(
                email: emailController.text.isEmpty ? null : emailController.text,
                phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                contactAddress: addressController.text.isEmpty ? null : addressController.text,
              );

              await _updateLecturerProfile(context, updatedLecturer);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStudentProfile(BuildContext context, Student student) async {
    final authService = context.read<AuthService>();
    if (authService.token == null) return;

    try {
      final apiService = ApiService();
      final response = await apiService.updateStudentProfile(authService.token!, student);

      if (response.success && response.data != null) {
        setState(() {
          _student = response.data;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _loadStudentProfile(authService.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateLecturerProfile(BuildContext context, Lecturer lecturer) async {
    final authService = context.read<AuthService>();
    if (authService.token == null) return;

    try {
      final apiService = ApiService();
      final response = await apiService.updateLecturerProfile(authService.token!, lecturer);

      if (response.success && response.data != null) {
        setState(() {
          _lecturer = response.data;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _loadLecturerProfile(authService.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showUpdateRelativeDialog(BuildContext context) {
    final emailController = TextEditingController(text: _relative?.email ?? '');
    final phoneController = TextEditingController(text: _relative?.phoneNumber ?? '');
    final addressController = TextEditingController(text: _relative?.contactAddress ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
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
              final updatedRelative = _relative!.copyWith(
                email: emailController.text.isEmpty ? null : emailController.text,
                phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                contactAddress: addressController.text.isEmpty ? null : addressController.text,
              );

              await _updateRelativeProfile(context, updatedRelative);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRelativeProfile(BuildContext context, Relative relative) async {
    final authService = context.read<AuthService>();
    if (authService.token == null) return;

    try {
      final apiService = ApiService();
      final response = await apiService.updateRelativeProfile(authService.token!, relative);

      if (response.success && response.data != null) {
        setState(() {
          _relative = response.data;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _loadRelativeProfile(authService.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

