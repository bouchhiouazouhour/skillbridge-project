import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../models/job_match.dart';
import 'job_match_results_screen.dart';
import 'cv_upload_screen.dart';

class JobMatchScreen extends StatefulWidget {
  const JobMatchScreen({super.key});

  @override
  State<JobMatchScreen> createState() => _JobMatchScreenState();
}

class _JobMatchScreenState extends State<JobMatchScreen> {
  final _apiService = ApiService();
  final _jobDescriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingCVs = true;
  List<dynamic> _cvHistory = [];
  int? _selectedCvId;
  String? _selectedCvName;
  
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
        _cvHistory = history.where((cv) => cv['status'] == 'completed').toList();
        _isLoadingCVs = false;
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

  bool get _canAnalyze {
    return _selectedCvId != null &&
        _jobDescriptionController.text.length >= 100;
  }

  Future<void> _analyzeMatch() async {
    if (!_canAnalyze) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final jobMatch = await _apiService.analyzeJobMatch(
        _selectedCvId!,
        _jobDescriptionController.text,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobMatchResultsScreen(jobMatch: jobMatch),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
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

  void _showCVSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.description, color: Colors.blue),
              SizedBox(width: 8),
              Text('Select CV'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _cvHistory.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inbox, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No CVs available',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CVUploadScreen(),
                            ),
                          ).then((_) => _loadCVHistory());
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload CV'),
                      ),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cvHistory.length,
                    itemBuilder: (context, index) {
                      final cv = _cvHistory[index];
                      final cvName = cv['filename'] ?? cv['original_name'] ?? 'Unknown';
                      final cvId = cv['id'];
                      final score = cv['ats_score'] ?? cv['score'] ?? 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getScoreColor(score),
                            child: Text(
                              '$score',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            cvName,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'ATS Score: $score%',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: _selectedCvId == cvId
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCvId = cvId;
                              _selectedCvName = cvName;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Match Analyzer'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.compare_arrows, size: 40, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Compare Your CV',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Paste a job description and see how well your CV matches the requirements',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // CV Selection Section
            const Text(
              'Select Your CV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CVUploadScreen(),
                        ),
                      ).then((_) => _loadCVHistory());
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload New CV'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingCVs ? null : _showCVSelectionDialog,
                    icon: _isLoadingCVs
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open),
                    label: const Text('From History'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Selected CV Card
            if (_selectedCvId != null)
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    _selectedCvName ?? 'CV Selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('CV selected for analysis'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedCvId = null;
                        _selectedCvName = null;
                      });
                    },
                  ),
                ),
              ),
            
            const SizedBox(height: 24),

            // Job Description Section
            const Text(
              'Paste Job Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jobDescriptionController,
              maxLines: 10,
              minLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Paste the full job posting including requirements, responsibilities, and qualifications...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              '${_jobDescriptionController.text.length} / 100 minimum characters',
              style: TextStyle(
                fontSize: 12,
                color: _jobDescriptionController.text.length >= 100
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Analyze Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading || !_canAnalyze ? null : _analyzeMatch,
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
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Requirements hint
            if (!_canAnalyze)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedCvId == null
                              ? 'Please select a CV to continue'
                              : 'Job description must be at least 100 characters',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
