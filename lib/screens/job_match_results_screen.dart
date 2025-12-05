import 'package:flutter/material.dart';
import '../models/job_match.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class JobMatchResultsScreen extends StatefulWidget {
  final JobMatch jobMatch;

  const JobMatchResultsScreen({super.key, required this.jobMatch});

  @override
  State<JobMatchResultsScreen> createState() => _JobMatchResultsScreenState();
}

class _JobMatchResultsScreenState extends State<JobMatchResultsScreen> {
  final _apiService = ApiService();
  bool _isSaving = false;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.jobMatch.isSaved;
  }

  List<Color> _getGradientColors() {
    switch (widget.jobMatch.verdict.toLowerCase()) {
      case 'strong':
        return [Colors.green.shade600, Colors.green.shade800];
      case 'moderate':
        return [Colors.orange.shade600, Colors.orange.shade800];
      case 'weak':
      default:
        return [Colors.red.shade600, Colors.red.shade800];
    }
  }

  IconData _getVerdictIcon() {
    switch (widget.jobMatch.verdict.toLowerCase()) {
      case 'strong':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'weak':
      default:
        return Icons.cancel;
    }
  }

  String _getVerdictMessage() {
    switch (widget.jobMatch.verdict.toLowerCase()) {
      case 'strong':
        return 'Strong Fit - Apply with Confidence!';
      case 'moderate':
        return 'Moderate Fit - Consider Improving';
      case 'weak':
      default:
        return 'Weak Fit - Significant Gaps';
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobMatch.jobTitle ?? 'Job Match Results'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card with Score
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(colors: _getGradientColors()),
                ),
                child: Column(
                  children: [
                    Icon(_getVerdictIcon(), size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.jobMatch.matchScore}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getVerdictMessage(),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.jobMatch.companyName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'at ${widget.jobMatch.companyName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Job Details Card
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
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Match Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (widget.jobMatch.jobTitle != null) ...[
                      _buildInfoRow(
                        Icons.work,
                        'Position',
                        widget.jobMatch.jobTitle!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (widget.jobMatch.companyName != null) ...[
                      _buildInfoRow(
                        Icons.business,
                        'Company',
                        widget.jobMatch.companyName!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _buildInfoRow(
                      Icons.insert_drive_file,
                      'CV ID',
                      '#${widget.jobMatch.cvId}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Analyzed',
                      _formatDate(widget.jobMatch.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.assessment,
                      'Match Score',
                      '${widget.jobMatch.matchScore}%',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.verified,
                      'Verdict',
                      widget.jobMatch.verdict.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Job Description Card
            if (widget.jobMatch.jobDescription.isNotEmpty) ...[
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
                      const Row(
                        children: [
                          Icon(Icons.description, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Job Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        widget.jobMatch.jobDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Your Strengths
            if (widget.jobMatch.strengths.isNotEmpty) ...[
              const Text(
                'Your Strengths',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.jobMatch.strengths.map(
                (strength) => Card(
                  color: Colors.green.shade50,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.amber.shade700),
                    title: Text(strength, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Skills You Have
            if (widget.jobMatch.matchingSkills.isNotEmpty) ...[
              const Text(
                'Skills You Have',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.jobMatch.matchingSkills
                    .map(
                      (skill) => Chip(
                        avatar: const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          skill,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Skills You Need
            if (widget.jobMatch.missingSkills.isNotEmpty) ...[
              const Text(
                'Skills You Need',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.jobMatch.missingSkills
                    .map(
                      (skill) => Chip(
                        avatar: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          skill,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // How to Improve
            if (widget.jobMatch.suggestions.isNotEmpty) ...[
              const Text(
                'How to Improve',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.jobMatch.suggestions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final suggestion = entry.value;
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade700,
                      radius: 14,
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Save to History Button
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
              Card(
                color: Colors.green.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
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
              ),
            const SizedBox(height: 16),

            // Back to Dashboard
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes;
      if (hours > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} ago';
      } else if (minutes > 0) {
        return '$minutes minute${minutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
