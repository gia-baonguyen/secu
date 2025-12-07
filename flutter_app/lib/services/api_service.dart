import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../models/gpa_data.dart';
import '../models/lecturer.dart';
import '../models/exam_question.dart';
import '../models/relative.dart';
import '../models/course.dart';
import '../models/audit_log.dart';
import '../models/deadline.dart';

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

  // =============================================
  // EXAM QUESTIONS ENDPOINTS (OLS Protected)
  // =============================================

  /// Get all exam questions
  /// OLS automatically filters based on user's authorization:
  /// - STUDENT: Only sees PUB
  /// - LECTURER: Sees PUB + INT:CS
  /// - DEAN: Sees PUB + INT:CS + CONF:CS
  /// - ADMIN: Sees all
  Future<ApiResponse<List<ExamQuestion>>> getExamQuestions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exam-questions'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final questions = (jsonData['data'] as List)
            .map((item) => ExamQuestion.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: questions,
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

  /// Get exam question by ID
  Future<ApiResponse<ExamQuestion>> getExamQuestionById(String token, int questionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exam-questions/$questionId'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => ExamQuestion.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get exam questions by subject code
  Future<ApiResponse<List<ExamQuestion>>> getExamQuestionsBySubject(String token, String subjectCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exam-questions/subject/$subjectCode'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final questions = (jsonData['data'] as List)
            .map((item) => ExamQuestion.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: questions,
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

  /// Search exam questions by keyword
  Future<ApiResponse<List<ExamQuestion>>> searchExamQuestions(String token, String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exam-questions/search?keyword=$keyword'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final questions = (jsonData['data'] as List)
            .map((item) => ExamQuestion.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: questions,
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

  /// Get available security labels for current user
  Future<ApiResponse<List<String>>> getAvailableLabels(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exam-questions/labels'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final labels = (jsonData['data'] as List)
            .map((item) => item.toString())
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: labels,
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

  /// Create a new exam question (LECTURER, DEAN, ADMIN only)
  Future<ApiResponse<ExamQuestion>> createExamQuestion(String token, ExamQuestion question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exam-questions'),
        headers: getHeaders(token),
        body: json.encode(question.toCreateJson()),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => ExamQuestion.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Update an exam question (LECTURER, DEAN, ADMIN only)
  Future<ApiResponse<ExamQuestion>> updateExamQuestion(String token, int questionId, ExamQuestion question) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/exam-questions/$questionId'),
        headers: getHeaders(token),
        body: json.encode(question.toUpdateJson()),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => ExamQuestion.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Delete an exam question (DEAN, ADMIN only)
  Future<ApiResponse<void>> deleteExamQuestion(String token, int questionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/exam-questions/$questionId'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
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

  // =============================================
  // RELATIVE ENDPOINTS
  // =============================================

  /// Get relative profile
  Future<ApiResponse<Relative>> getRelativeProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/relatives/me'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Relative.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Update relative profile
  Future<ApiResponse<Relative>> updateRelativeProfile(String token, Relative relative) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/relatives/me'),
        headers: getHeaders(token),
        body: json.encode(relative.toUpdateJson()),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Relative.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get children linked to relative
  Future<ApiResponse<List<Student>>> getRelativeChildren(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/relatives/children'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final children = (jsonData['data'] as List)
            .map((item) => Student.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: children,
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

  /// Get grades for a specific child
  Future<ApiResponse<List<Grade>>> getChildGrades(String token, String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/relatives/children/$studentId/grades'),
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
  // DEAN ENDPOINTS
  // =============================================

  /// Get faculty info
  Future<ApiResponse<Map<String, dynamic>>> getDeanFacultyInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dean/faculty'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get all students in faculty (Dean)
  Future<ApiResponse<List<Student>>> getDeanStudents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dean/students'),
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

  /// Get all lecturers in faculty (Dean)
  Future<ApiResponse<List<Lecturer>>> getDeanLecturers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dean/lecturers'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final lecturers = (jsonData['data'] as List)
            .map((item) => Lecturer.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: lecturers,
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

  /// Get all grades in faculty (Dean)
  Future<ApiResponse<List<Grade>>> getDeanGrades(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dean/grades'),
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

  /// Get faculty statistics (Dean)
  Future<ApiResponse<Map<String, dynamic>>> getDeanStatistics(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dean/statistics'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // =============================================
  // DEPARTMENT HEAD ENDPOINTS
  // =============================================

  /// Get department info
  Future<ApiResponse<Map<String, dynamic>>> getDepartmentInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/department-head/department'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get all lecturers in department
  Future<ApiResponse<List<Lecturer>>> getDepartmentLecturers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/department-head/lecturers'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final lecturers = (jsonData['data'] as List)
            .map((item) => Lecturer.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: lecturers,
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

  /// Get all courses in department
  Future<ApiResponse<List<Course>>> getDepartmentCourses(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/department-head/courses'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final courses = (jsonData['data'] as List)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: courses,
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

  /// Get all grades in department
  Future<ApiResponse<List<Grade>>> getDepartmentGrades(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/department-head/grades'),
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

  /// Get department statistics
  Future<ApiResponse<Map<String, dynamic>>> getDepartmentStatistics(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/department-head/statistics'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  // =============================================
  // ACADEMIC AFFAIRS ENDPOINTS
  // =============================================

  /// Get all students (Academic Affairs - full access)
  Future<ApiResponse<List<Student>>> getAcademicStudents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/students'),
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

  /// Get all lecturers (Academic Affairs)
  Future<ApiResponse<List<Lecturer>>> getAcademicLecturers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/lecturers'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final lecturers = (jsonData['data'] as List)
            .map((item) => Lecturer.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: lecturers,
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

  /// Get all grades (Academic Affairs)
  Future<ApiResponse<List<Grade>>> getAcademicGrades(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/grades'),
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

  /// Update grade (Academic Affairs - can modify after deadline)
  Future<ApiResponse<Grade>> updateAcademicGrade(String token, int gradeId, Grade grade, String? reason) async {
    try {
      final body = grade.toUpdateJson();
      if (reason != null) {
        body['modificationReason'] = reason;
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/academic/grades/$gradeId'),
        headers: getHeaders(token),
        body: json.encode(body),
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

  /// Approve grade (Academic Affairs)
  Future<ApiResponse<Grade>> approveGrade(String token, int gradeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/grades/$gradeId/approve'),
        headers: getHeaders(token),
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

  /// Get system statistics (Academic Affairs)
  Future<ApiResponse<Map<String, dynamic>>> getAcademicStatistics(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/statistics'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get audit logs (Academic Affairs)
  Future<ApiResponse<List<AuditLog>>> getAuditLogs(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/audit-logs'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final logs = (jsonData['data'] as List)
            .map((item) => AuditLog.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: logs,
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

  /// Get audit logs by table (Academic Affairs)
  Future<ApiResponse<List<AuditLog>>> getAuditLogsByTable(String token, String tableName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/audit-logs/table/$tableName'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final logs = (jsonData['data'] as List)
            .map((item) => AuditLog.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: logs,
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
  // COURSE ENDPOINTS
  // =============================================

  /// Get all courses
  Future<ApiResponse<List<Course>>> getCourses(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final courses = (jsonData['data'] as List)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: courses,
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

  /// Get course by ID
  Future<ApiResponse<Course>> getCourseById(String token, String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => Course.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get courses by department
  Future<ApiResponse<List<Course>>> getCoursesByDepartment(String token, String departmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/department/$departmentId'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final courses = (jsonData['data'] as List)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: courses,
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

  /// Search courses by keyword
  Future<ApiResponse<List<Course>>> searchCourses(String token, String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/search?keyword=$keyword'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final courses = (jsonData['data'] as List)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: courses,
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
  // DEADLINE ENDPOINTS
  // =============================================

  /// Get all deadlines
  Future<ApiResponse<List<GradeSubmissionDeadline>>> getDeadlines(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/deadlines'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final deadlines = (jsonData['data'] as List)
            .map((item) => GradeSubmissionDeadline.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: jsonData['success'] ?? false,
          message: jsonData['message'],
          data: deadlines,
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

  /// Get current active deadline
  Future<ApiResponse<GradeSubmissionDeadline>> getCurrentDeadline(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/deadlines/current'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => GradeSubmissionDeadline.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Get deadline by semester and year
  Future<ApiResponse<GradeSubmissionDeadline>> getDeadline(String token, String semester, int year) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/deadlines/semester/$semester/year/$year'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse.fromJson(
        jsonData,
        (data) => GradeSubmissionDeadline.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Check if deadline has passed
  Future<ApiResponse<bool>> checkDeadline(String token, String semester, int academicYear) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/deadlines/check?semester=$semester&academicYear=$academicYear'),
        headers: getHeaders(token),
      );

      final jsonData = json.decode(response.body);
      return ApiResponse(
        success: jsonData['success'] ?? false,
        message: jsonData['message'],
        data: jsonData['data'] as bool? ?? false,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: false,
      );
    }
  }
}

