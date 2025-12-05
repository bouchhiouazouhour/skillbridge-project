import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  final _jobDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isLoadingCVs = true;
  List<dynamic> _cvHistory = [];
  int? _selectedCvId;
  PlatformFile? _uploadedFile;
  bool _useExistingCV = true;

  @override
  void initState() {
    super.initState();
    _loadCVHistory();
  }

  @override
  void dispose() {
    _jobDescriptionController.dispose();
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
            content: Text('Error loading CV history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _uploadedFile = result.files.single;
          _useExistingCV = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeMatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_useExistingCV && _selectedCvId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a CV or upload a new one'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_useExistingCV && _uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a CV file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response;

      if (_useExistingCV) {
        response = await _apiService.matchJob(
          _jobDescriptionController.text,
          _selectedCvId!,
        );
      } else {
        response = await _apiService.matchJobWithFile(
          _jobDescriptionController.text,
          _uploadedFile!,
        );
      }

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
        throw Exception(response['error'] ?? 'Analysis failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
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
      body: _isLoading ? _buildLoadingView() : _buildFormView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue.shade700),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your fit for this role...',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a moment',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
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
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
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
                      'Compare Your CV to a Job',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Paste a job description and select your CV to see how well you match',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Job Description Section
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _jobDescriptionController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    'Paste the full job description here...\n\nInclude requirements, responsibilities, and qualifications for best results.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a job description';
                }
                if (value.length < 50) {
                  return 'Job description must be at least 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // CV Selection Section
            const Text(
              'Select Your CV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Toggle between existing CV and upload
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _useExistingCV = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _useExistingCV
                            ? Colors.blue.shade700
                            : Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'From History',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _useExistingCV ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _useExistingCV = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_useExistingCV
                            ? Colors.blue.shade700
                            : Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Upload New',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              !_useExistingCV ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show CV selection based on toggle
            if (_useExistingCV) ...[
              if (_isLoadingCVs)
                const Center(child: CircularProgressIndicator())
              else if (_cvHistory.isEmpty)
                Card(
                  color: Colors.orange.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No CVs found. Please upload a CV first or switch to "Upload New" tab.',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<int>(
                      value: _selectedCvId,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: _cvHistory.map<DropdownMenuItem<int>>((cv) {
                        return DropdownMenuItem<int>(
                          value: cv['id'],
                          child: Text(
                            cv['filename'] ?? cv['original_name'] ?? 'CV #${cv['id']}',
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
                  ),
                ),
            ] else ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.blue.shade700,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          _uploadedFile == null
                              ? Icons.cloud_upload
                              : Icons.check_circle,
                          size: 48,
                          color: _uploadedFile == null
                              ? Colors.blue.shade700
                              : Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _uploadedFile == null
                              ? 'Tap to select file'
                              : 'File selected:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (_uploadedFile != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _uploadedFile!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Analyze Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _analyzeMatch,
                icon: const Icon(Icons.analytics),
                label: const Text(
                  'Analyze Match',
                  style: TextStyle(
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
                        Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
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
                    _buildInfoItem('✓ Skills you have vs. missing'),
                    _buildInfoItem('✓ Specific improvement suggestions'),
                    _buildInfoItem('✓ Your strengths for this role'),
                  ],
                ),
              ),
            ),
          ],
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
