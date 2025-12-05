import 'package:flutter/material.dart';
import '../models/job_match.dart';
import '../services/api_service.dart';
import 'job_match_screen.dart';
import 'cv_upload_screen.dart';

class JobMatchResultsScreen extends StatefulWidget {
  final JobMatch jobMatch;

  const JobMatchResultsScreen({super.key, required this.jobMatch});

  @override
  State<JobMatchResultsScreen> createState() => _JobMatchResultsScreenState();
}

class _JobMatchResultsScreenState extends State<JobMatchResultsScreen> {
  final _apiService = ApiService();
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.jobMatch.isSaved;
  }

  Color _getVerdictColor() {
    switch (widget.jobMatch.matchVerdict.toLowerCase()) {
      case 'strong':
        return const Color(0xFF4CAF50); // Green
      case 'moderate':
        return const Color(0xFFFF9800); // Orange
      case 'weak':
      default:
        return const Color(0xFFF44336); // Red
    }
  }

  String _getVerdictText() {
    switch (widget.jobMatch.matchVerdict.toLowerCase()) {
      case 'strong':
        return 'Strong Fit';
      case 'moderate':
        return 'Moderate Fit';
      case 'weak':
      default:
        return 'Weak Fit';
    }
  }

  Future<void> _saveToHistory() async {
    if (_isSaved || widget.jobMatch.id == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.saveJobMatch(widget.jobMatch.id!);
      setState(() {
        _isSaved = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to history!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor();
    final score = widget.jobMatch.matchScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Results'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card with Match Score
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      verdictColor.withOpacity(0.8),
                      verdictColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Circular Progress Indicator
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: score / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$score%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Match',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getVerdictText(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getVerdictDescription(),
                      style: const TextStyle(
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

            // Strengths Section
            if (widget.jobMatch.strengths.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.star,
                'Your Strengths',
                Colors.amber,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: widget.jobMatch.strengths
                        .map((strength) => _buildStrengthItem(strength))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Matching Skills Section
            if (widget.jobMatch.matchingSkills.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.check_circle,
                'Matching Skills',
                Colors.green,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.jobMatch.matchingSkills
                    .map((skill) => Chip(
                          avatar: const Icon(Icons.check,
                              size: 18, color: Colors.green),
                          label: Text(skill),
                          backgroundColor: Colors.green.shade50,
                          labelStyle: TextStyle(color: Colors.green.shade800),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Missing Skills Section
            if (widget.jobMatch.missingSkills.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.warning,
                'Missing Skills',
                Colors.orange,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.jobMatch.missingSkills
                    .map((skill) => Chip(
                          avatar: const Icon(Icons.close,
                              size: 18, color: Colors.red),
                          label: Text(skill),
                          backgroundColor: Colors.red.shade50,
                          labelStyle: TextStyle(color: Colors.red.shade800),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Improvement Suggestions Section
            if (widget.jobMatch.improvementSuggestions.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.lightbulb,
                'Improvement Suggestions',
                Colors.blue,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: widget.jobMatch.improvementSuggestions
                        .asMap()
                        .entries
                        .map((entry) =>
                            _buildSuggestionItem(entry.key + 1, entry.value))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (!_isSaved)
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveToHistory,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bookmark_add),
                  label: Text(_isSaving ? 'Saving...' : 'Save to History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Saved to History',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobMatchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Another Job'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CVUploadScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Update My CV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getVerdictDescription() {
    switch (widget.jobMatch.matchVerdict.toLowerCase()) {
      case 'strong':
        return 'Great match! You\'re a strong candidate for this position.';
      case 'moderate':
        return 'Decent match with some areas for improvement.';
      case 'weak':
      default:
        return 'Significant gaps exist between your profile and job requirements.';
    }
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthItem(String strength) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strength,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(int number, String suggestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
