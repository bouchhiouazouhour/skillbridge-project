import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/job_match.dart';
import 'job_match_results_screen.dart';

class JobMatchScreen extends StatefulWidget {
  const JobMatchScreen({super.key});

  @override
  State<JobMatchScreen> createState() => _JobMatchScreenState();
}

class _JobMatchScreenState extends State<JobMatchScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _jobDescriptionController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCVs = true;
  List<dynamic> _cvHistory = [];
  int? _selectedCvId;

  @override
  void initState() {
    super.initState();
    _loadCVHistory();
  }

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    _jobTitleController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCVHistory() async {
    try {
      final history = await _apiService.getCVHistory();
      setState(() {
        _cvHistory = history;
        _isLoadingCVs = false;
        if (history.isNotEmpty) {
          _selectedCvId = history.first['id'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCVs = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading CVs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeMatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCvId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a CV first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.analyzeJobMatch(
        cvId: _selectedCvId!,
        jobDescription: _jobDescriptionController.text,
        jobTitle: _jobTitleController.text.isNotEmpty
            ? _jobTitleController.text
            : null,
        companyName: _companyNameController.text.isNotEmpty
            ? _companyNameController.text
            : null,
      );

      if (response['success'] == true && response['job_match'] != null) {
        final jobMatch = JobMatch.fromJson(response['job_match']);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobMatchResultsScreen(jobMatch: jobMatch),
            ),
          );
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to analyze job match');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Match Analyzer'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingCVs
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade800
                            ],
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Compare Your CV to Job Postings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Get AI-powered analysis to see how well you match',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Job Title (Optional)
                    TextFormField(
                      controller: _jobTitleController,
                      decoration: InputDecoration(
                        labelText: 'Job Title (Optional)',
                        hintText: 'e.g., Senior Software Engineer',
                        prefixIcon: const Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Company Name (Optional)
                    TextFormField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: 'Company Name (Optional)',
                        hintText: 'e.g., Google, Microsoft',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Job Description
                    TextFormField(
                      controller: _jobDescriptionController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Job Description *',
                        hintText:
                            'Paste the full job description here (min 50 characters)',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 140),
                          child: Icon(Icons.description),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the job description';
                        }
                        if (value.length < 50) {
                          return 'Job description must be at least 50 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // CV Selection
                    const Text(
                      'Select Your CV',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_cvHistory.isEmpty)
                      Card(
                        color: Colors.orange.shade50,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No CVs uploaded yet. Please upload a CV first.',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<int>(
                                value: _selectedCvId,
                                decoration: InputDecoration(
                                  labelText: 'Choose CV from History',
                                  prefixIcon: const Icon(Icons.folder_open),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _cvHistory.map<DropdownMenuItem<int>>(
                                    (cv) {
                                  return DropdownMenuItem<int>(
                                    value: cv['id'],
                                    child: Text(
                                      cv['filename'] ?? 'Unnamed CV',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCvId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Analyze Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading || _cvHistory.isEmpty
                            ? null
                            : _analyzeMatch,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.analytics),
                        label: Text(
                          _isLoading ? 'Analyzing...' : 'Analyze Match',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'What you\'ll get:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoItem('✓ Match score (0-100%)'),
                            _buildInfoItem('✓ Skills that match the job'),
                            _buildInfoItem('✓ Skills you need to add'),
                            _buildInfoItem('✓ Specific improvement tips'),
                            _buildInfoItem('✓ Your strengths for this role'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
