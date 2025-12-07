import 'package:flutter/material.dart';
import '../models/exam_question.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

/// ExamQuestionsScreen
/// Displays exam questions protected by Oracle Label Security (OLS)
/// OLS automatically filters questions based on user's authorization level
class ExamQuestionsScreen extends StatefulWidget {
  const ExamQuestionsScreen({super.key});

  @override
  State<ExamQuestionsScreen> createState() => _ExamQuestionsScreenState();
}

class _ExamQuestionsScreenState extends State<ExamQuestionsScreen> {
  final ApiService _apiService = ApiService();

  List<ExamQuestion> _questions = [];
  List<String> _availableLabels = [];
  bool _isLoading = true;
  String? _error;
  String? _userRole;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
    final authService = Provider.of<AuthService>(context, listen: false);

  if (authService.token == null) return;
      final token = authService.token!;
    final role = await authService.currentUser?.role;
      
      if (token == null) {
        setState(() {
          _error = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }

      _userRole = role;

      // Load questions
      final questionsResponse = await _apiService.getExamQuestions(token);
      
      // Load available labels (for create/edit)
      if (_canCreateQuestion()) {
        final labelsResponse = await _apiService.getAvailableLabels(token);
        if (labelsResponse.success && labelsResponse.data != null) {
          _availableLabels = labelsResponse.data!;
        }
      }

      setState(() {
        if (questionsResponse.success && questionsResponse.data != null) {
          _questions = questionsResponse.data!;
        } else {
          _error = questionsResponse.message ?? 'Failed to load questions';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _canCreateQuestion() {
    return _userRole == 'LECTURER' || _userRole == 'DEAN' || _userRole == 'ADMIN';
  }

  bool _canDeleteQuestion() {
    return _userRole == 'DEAN' || _userRole == 'ADMIN';
  }

  List<ExamQuestion> get _filteredQuestions {
    if (_searchQuery.isEmpty) return _questions;
    return _questions.where((q) =>
        q.questionText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (q.subjectCode?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  Color _getLabelColor(String? label) {
    switch (label) {
      case 'PUB':
        return Colors.green;
      case 'INT:CS':
        return Colors.blue;
      case 'INT:EE':
        return Colors.orange;
      case 'CONF:CS':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLabelIcon(String? label) {
    switch (label) {
      case 'PUB':
        return Icons.public;
      case 'INT:CS':
      case 'INT:EE':
        return Icons.lock_open;
      case 'CONF:CS':
        return Icons.lock;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _showCreateDialog() async {
    final subjectController = TextEditingController();
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    String? selectedLabel = _availableLabels.isNotEmpty ? _availableLabels.first : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code',
                    hintText: 'e.g., CS101',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question Text',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Correct Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLabel,
                  decoration: const InputDecoration(
                    labelText: 'Security Label',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableLabels.map((label) => DropdownMenuItem(
                    value: label,
                    child: Row(
                      children: [
                        Icon(_getLabelIcon(label), color: _getLabelColor(label), size: 20),
                        const SizedBox(width: 8),
                        Text(label),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedLabel = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (questionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question text is required')),
                  );
                  return;
                }

                Navigator.pop(context);

                   final authService = Provider.of<AuthService>(context, listen: false);

                   if (authService.token == null) return;
                  final token = authService.token!;

                final question = ExamQuestion(
                  subjectCode: subjectController.text,
                  questionText: questionController.text,
                  correctAnswer: answerController.text,
                  securityLabel: selectedLabel,
                );

                final response = await _apiService.createExamQuestion(token, question);

                if (mounted) {
                  if (response.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Question created successfully')),
                    );
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.message ?? 'Failed to create question')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(ExamQuestion question) async {
    final subjectController = TextEditingController(text: question.subjectCode);
    final questionController = TextEditingController(text: question.questionText);
    final answerController = TextEditingController(text: question.correctAnswer);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Question'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getLabelColor(question.securityLabel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getLabelIcon(question.securityLabel), 
                         color: _getLabelColor(question.securityLabel)),
                    const SizedBox(width: 8),
                    Text('Security: ${question.securityLabelDisplay}',
                         style: TextStyle(color: _getLabelColor(question.securityLabel))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Correct Answer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

                  final authService = Provider.of<AuthService>(context, listen: false);

  if (authService.token == null) return;
      final token = authService.token!;

              if (token == null || question.questionId == null) return;

              final updatedQuestion = question.copyWith(
                subjectCode: subjectController.text,
                questionText: questionController.text,
                correctAnswer: answerController.text,
              );

              final response = await _apiService.updateExamQuestion(
                token, 
                question.questionId!, 
                updatedQuestion
              );

              if (mounted) {
                if (response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question updated successfully')),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response.message ?? 'Failed to update question')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuestion(ExamQuestion question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text('Are you sure you want to delete this question?\n\n"${question.questionText}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || question.questionId == null) return;

        final authService = Provider.of<AuthService>(context, listen: false);

  if (authService.token == null) return;
      final token = authService.token!;

    final response = await _apiService.deleteExamQuestion(token, question.questionId!);

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question deleted successfully')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to delete question')),
        );
      }
    }
  }

  void _showQuestionDetail(ExamQuestion question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getLabelColor(question.securityLabel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getLabelIcon(question.securityLabel), 
                             color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          question.securityLabelDisplay,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (question.subjectCode != null)
                    Chip(
                      label: Text(question.subjectCode!),
                      backgroundColor: Colors.grey[200],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Question',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question.questionText,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              if (question.correctAnswer != null && question.correctAnswer!.isNotEmpty) ...[
                const Text(
                  'Answer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    question.correctAnswer!,
                    style: TextStyle(fontSize: 16, color: Colors.green[800]),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Created by: ${question.createdBy ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (question.createdDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${question.createdDate!.toLocal().toString().substring(0, 16)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              if (_canCreateQuestion())
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(question);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    if (_canDeleteQuestion()) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteQuestion(question);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Questions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'OLS filters questions based on your role: ${_userRole ?? "Unknown"}',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredQuestions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No questions match your search'
                                      : 'No questions available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredQuestions.length,
                              itemBuilder: (context, index) {
                                final question = _filteredQuestions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () => _showQuestionDetail(question),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getLabelColor(question.securityLabel),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getLabelIcon(question.securityLabel),
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      question.securityLabel ?? 'Unknown',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              if (question.subjectCode != null)
                                                Text(
                                                  question.subjectCode!,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            question.questionText,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.person_outline, 
                                                   size: 14, color: Colors.grey[500]),
                                              const SizedBox(width: 4),
                                              Text(
                                                question.createdBy ?? 'Unknown',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(Icons.arrow_forward_ios, 
                                                   size: 14, color: Colors.grey[400]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: _canCreateQuestion()
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Question'),
            )
          : null,
    );
  }
}

