import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/job_match.dart';
import 'job_match_screen.dart';

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

  Future<void> _saveToHistory() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.saveJobMatch(widget.jobMatch.id);
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
            content: Text('Failed to save: ${e.toString()}'),
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

  Color _getVerdictColor() {
    switch (widget.jobMatch.matchVerdict.toLowerCase()) {
      case 'strong':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'weak':
      default:
        return Colors.red;
    }
  }

  String _getVerdictMessage() {
    switch (widget.jobMatch.matchVerdict.toLowerCase()) {
      case 'strong':
        return 'Apply with Confidence!';
      case 'moderate':
        return 'Good Fit with Some Improvements';
      case 'weak':
      default:
        return 'Consider Building More Skills';
    }
  }

  IconData _getVerdictIcon() {
    switch (widget.jobMatch.matchVerdict.toLowerCase()) {
      case 'strong':
        return Icons.check_circle;
      case 'moderate':
        return Icons.info;
      case 'weak':
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = _getVerdictColor();

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
            // Match Score Card
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
                  ),
                ),
                child: Column(
                  children: [
                    // Circular Progress Indicator for Score
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: widget.jobMatch.matchScore / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.white30,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.jobMatch.matchScore}%',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Match',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Verdict Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getVerdictIcon(),
                            color: verdictColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.jobMatch.matchVerdict.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: verdictColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getVerdictMessage(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Strengths Section
            if (widget.jobMatch.strengths.isNotEmpty) ...[
              _buildSectionHeader(
                'Your Strengths',
                Icons.star,
                Colors.amber,
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: widget.jobMatch.strengths
                        .map((strength) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      strength,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Matching Skills Section
            if (widget.jobMatch.matchingSkills.isNotEmpty) ...[
              _buildSectionHeader(
                'Matching Skills',
                Icons.thumb_up,
                Colors.green,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.jobMatch.matchingSkills
                    .map((skill) => Chip(
                          avatar: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            skill,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Missing Skills Section
            if (widget.jobMatch.missingSkills.isNotEmpty) ...[
              _buildSectionHeader(
                'Missing Skills',
                Icons.warning_amber,
                Colors.red,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.jobMatch.missingSkills
                    .map((skill) => Chip(
                          avatar: const Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            skill,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red.shade400,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Improvement Suggestions Section
            if (widget.jobMatch.improvementSuggestions.isNotEmpty) ...[
              _buildSectionHeader(
                'Improvement Suggestions',
                Icons.lightbulb,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: widget.jobMatch.improvementSuggestions
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (!_isSaved)
              SizedBox(
                height: 56,
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
                      : const Icon(Icons.bookmark),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save to History',
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
              )
            else
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Saved to History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
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
                label: const Text(
                  'Try Another Job',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
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
}
