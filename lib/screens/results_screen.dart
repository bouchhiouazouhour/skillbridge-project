import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cv_analysis.dart';

class ResultsScreen extends StatefulWidget {
  final int cvId;

  const ResultsScreen({super.key, required this.cvId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  CVAnalysis? _analysis;
  Map<String, dynamic>? _scoreData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      // Simulate analysis time
      await Future.delayed(const Duration(seconds: 2));

      final results = await _apiService.getResults(widget.cvId);
      final scoreData = await _apiService.getScore(widget.cvId);

      if (results['analysis'] != null) {
        setState(() {
          _analysis = CVAnalysis.fromJson(results['analysis']);
          _scoreData = scoreData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analyzing CV'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 24),
              const Text(
                'Analyzing your CV...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'This may take a moment',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load results',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Analysis Results'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success message
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade800],
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your CV has been optimized!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Overall Score: ${_analysis?.score ?? 0}/100',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Score breakdown
            const Text(
              'Score Breakdown',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreCard(
              'Skills',
              _analysis?.skillsScore ?? 0,
              Icons.stars,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
              'Completeness',
              _analysis?.completenessScore ?? 0,
              Icons.checklist,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
              'ATS Compatibility',
              _analysis?.atsScore ?? 0,
              Icons.computer,
              Colors.purple,
            ),
            const SizedBox(height: 24),
            // Identified Skills
            if (_analysis?.skills.isNotEmpty ?? false) ...[
              const Text(
                'Identified Skills',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _analysis!.skills
                    .take(10)
                    .map((skill) => Chip(
                          label: Text(skill),
                          backgroundColor: Colors.blue.shade100,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
            // Missing Sections
            if (_analysis?.missingSections.isNotEmpty ?? false) ...[
              const Text(
                'Missing Sections',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._analysis!.missingSections.map((section) => Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.orange),
                      title: Text(
                        'Missing: ${section.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Consider adding a $section section'),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            // Suggestions
            if (_analysis?.suggestions.isNotEmpty ?? false) ...[
              const Text(
                'Improvement Suggestions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._analysis!.suggestions.map((suggestion) => Card(
                    child: ExpansionTile(
                      leading: Icon(
                        _getPriorityIcon(suggestion.priority),
                        color: _getPriorityColor(suggestion.priority),
                      ),
                      title: Text(suggestion.message),
                      subtitle: Text('Priority: ${suggestion.priority}'),
                      children: [
                        if (suggestion.example != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              suggestion.example!,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            // View Insights Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to detailed insights
                },
                icon: const Icon(Icons.insights),
                label: const Text(
                  'View Detailed Insights',
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
            const SizedBox(height: 12),
            // Export Button
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await _apiService.exportPDF(widget.cvId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PDF export completed!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Export failed: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text(
                  'Export Optimized CV',
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
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int score, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.low_priority;
      default:
        return Icons.info;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
