class CVAnalysis {
  final int id;
  final int cvId;
  final List<String> skills;
  final List<String> missingSections;
  final List<Suggestion> suggestions;
  final int score;
  final int skillsScore;
  final int completenessScore;
  final int atsScore;

  CVAnalysis({
    required this.id,
    required this.cvId,
    required this.skills,
    required this.missingSections,
    required this.suggestions,
    required this.score,
    required this.skillsScore,
    required this.completenessScore,
    required this.atsScore,
  });

  factory CVAnalysis.fromJson(Map<String, dynamic> json) {
    // Parse suggestions - handle both string array and object array
    List<Suggestion> parsedSuggestions = [];
    if (json['suggestions'] != null) {
      final suggestionsList = json['suggestions'] as List<dynamic>;
      parsedSuggestions = suggestionsList.map((s) {
        if (s is String) {
          // Convert string to Suggestion object
          return Suggestion(type: 'general', priority: 'medium', message: s);
        } else if (s is Map<String, dynamic>) {
          return Suggestion.fromJson(s);
        } else {
          return Suggestion(
            type: 'general',
            priority: 'medium',
            message: s.toString(),
          );
        }
      }).toList();
    }

    return CVAnalysis(
      id: json['id'] ?? 0,
      cvId: json['cv_id'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      missingSections: List<String>.from(json['missing_sections'] ?? []),
      suggestions: parsedSuggestions,
      score: json['score'] ?? 0,
      skillsScore: json['skills_score'] ?? 0,
      completenessScore: json['completeness_score'] ?? 0,
      atsScore: json['ats_score'] ?? 0,
    );
  }
}

class Suggestion {
  final String type;
  final String priority;
  final String message;
  final String? example;

  Suggestion({
    required this.type,
    required this.priority,
    required this.message,
    this.example,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'low',
      message: json['message'] ?? '',
      example: json['example'],
    );
  }
}
