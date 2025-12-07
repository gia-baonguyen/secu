import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../models/gpa_data.dart';
import '../models/lecturer.dart';

import 'dart:io';

class ApiService {
  // Use 10.0.2.2 for Android emulator (maps to host's localhost)
  // Use localhost for iOS simulator and web
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api';
    } else {
      return 'http://localhost:8081/api';
    }
  }
  
  // Headers
  Map<String, String> getHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Health Check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actuator/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Database Connection Test
  Future<Map<String, dynamic>?> testDatabaseConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test/db-connection'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Login
  Future<ApiResponse<LoginResponse>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(null),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Get Profile
  Future<ApiResponse<User>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Get Student Profile
  Future<ApiResponse<Student>> getStudentProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/me'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Student.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Get Student Grades
  Future<ApiResponse<List<Grade>>> getStudentGrades(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/me/grades'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final grades = (jsonData['data'] as List)
            .map((item) => Grade.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: grades,
        );
      }
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: [],
      );
    }
  }

  // Get Student GPA
  Future<ApiResponse<GpaData>> getStudentGpa(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/me/gpa'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => GpaData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // =============================================
  // LECTURER ENDPOINTS
  // =============================================

  // Get Lecturer Students
  Future<ApiResponse<List<Student>>> getLecturerStudents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lecturers/me/students'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final students = (jsonData['data'] as List)
            .map((item) => Student.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: students,
        );
      }
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: [],
      );
    }
  }

  // Get Lecturer Grades
  Future<ApiResponse<List<Grade>>> getLecturerGrades(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lecturers/me/grades'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final grades = (jsonData['data'] as List)
            .map((item) => Grade.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: grades,
        );
      }
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: [],
      );
    }
  }

  // Get Grades for a specific student (Lecturer only)
  Future<ApiResponse<List<Grade>>> getLecturerStudentGrades(String token, String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lecturers/me/students/$studentId/grades'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final grades = (jsonData['data'] as List)
            .map((item) => Grade.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: grades,
        );
      }
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: [],
      );
    }
  }

  // =============================================
  // ADMIN ENDPOINTS
  // =============================================

  // Get All Students (Admin)
  Future<ApiResponse<List<Student>>> getAllStudents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final students = (jsonData['data'] as List)
            .map((item) => Student.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: students,
        );
      }
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: [],
      );
    }
  }

  // Get All Grades (Admin)
  Future<ApiResponse<List<Grade>>> getAllGrades(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grades'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final grades = (jsonData['data'] as List)
            .map((item) => Grade.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: grades,
        );
      }
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: [],
      );
    }
  }

  // =============================================
  // UPDATE ENDPOINTS
  // =============================================

  // Update Student Profile
  Future<ApiResponse<Student>> updateStudentProfile(String token, Student student) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/me'),
        headers: getHeaders(token),
        body: json.encode(student.toUpdateJson()),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Student.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Get Lecturer Profile
  Future<ApiResponse<Lecturer>> getLecturerProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lecturers/me'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Lecturer.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Update Lecturer Profile
  Future<ApiResponse<Lecturer>> updateLecturerProfile(String token, Lecturer lecturer) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/lecturers/me'),
        headers: getHeaders(token),
        body: json.encode(lecturer.toUpdateJson()),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Lecturer.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Update Grade (Lecturer only)
  Future<ApiResponse<Grade>> updateGrade(String token, int gradeId, Grade grade) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/lecturers/me/grades/$gradeId'),
        headers: getHeaders(token),
        body: json.encode(grade.toUpdateJson()),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Grade.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

