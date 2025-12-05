class JobMatch {
  final int id;
  final int cvId;
  final String jobDescription;
  final int matchScore;
  final String matchVerdict;
  final List<String> matchingSkills;
  final List<String> missingSkills;
  final List<String> improvementSuggestions;
  final List<String> strengths;
  final bool isSaved;
  final DateTime createdAt;
  final String? cvName;

  JobMatch({
    required this.id,
    required this.cvId,
    required this.jobDescription,
    required this.matchScore,
    required this.matchVerdict,
    required this.matchingSkills,
    required this.missingSkills,
    required this.improvementSuggestions,
    required this.strengths,
    required this.isSaved,
    required this.createdAt,
    this.cvName,
  });

  factory JobMatch.fromJson(Map<String, dynamic> json) {
    // Handle nested cv object for cv_name
    String? cvName;
    if (json['cv'] != null && json['cv'] is Map) {
      cvName = json['cv']['original_name'];
    }

    return JobMatch(
      id: json['id'] ?? 0,
      cvId: json['cv_id'] ?? 0,
      jobDescription: json['job_description'] ?? '',
      matchScore: json['match_score'] ?? 0,
      matchVerdict: json['match_verdict'] ?? 'weak',
      matchingSkills: List<String>.from(json['matching_skills'] ?? []),
      missingSkills: List<String>.from(json['missing_skills'] ?? []),
      improvementSuggestions:
          List<String>.from(json['improvement_suggestions'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      isSaved: json['is_saved'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      cvName: cvName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cv_id': cvId,
      'job_description': jobDescription,
      'match_score': matchScore,
      'match_verdict': matchVerdict,
      'matching_skills': matchingSkills,
      'missing_skills': missingSkills,
      'improvement_suggestions': improvementSuggestions,
      'strengths': strengths,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
