class JobMatch {
  final int id;
  final int cvId;
  final String jobDescription;
  final String? jobTitle;
  final String? companyName;
  final int matchScore;
  final String verdict; // strong, moderate, weak
  final List<String> matchingSkills;
  final List<String> missingSkills;
  final List<String> suggestions;
  final List<String> strengths;
  final bool isSaved;
  final DateTime createdAt;

  JobMatch({
    required this.id,
    required this.cvId,
    required this.jobDescription,
    this.jobTitle,
    this.companyName,
    required this.matchScore,
    required this.verdict,
    required this.matchingSkills,
    required this.missingSkills,
    required this.suggestions,
    required this.strengths,
    required this.isSaved,
    required this.createdAt,
  });

  factory JobMatch.fromJson(Map<String, dynamic> json) {
    return JobMatch(
      id: json['id'] ?? 0,
      cvId: json['cv_id'] ?? 0,
      jobDescription: json['job_description'] ?? '',
      jobTitle: json['job_title'],
      companyName: json['company_name'],
      matchScore: json['match_score'] ?? 0,
      verdict: json['match_verdict'] ?? 'weak',
      matchingSkills: List<String>.from(json['matching_skills'] ?? []),
      missingSkills: List<String>.from(json['missing_skills'] ?? []),
      suggestions: List<String>.from(json['improvement_suggestions'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      isSaved: json['is_saved'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cv_id': cvId,
      'job_description': jobDescription,
      'job_title': jobTitle,
      'company_name': companyName,
      'match_score': matchScore,
      'match_verdict': verdict,
      'matching_skills': matchingSkills,
      'missing_skills': missingSkills,
      'improvement_suggestions': suggestions,
      'strengths': strengths,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
