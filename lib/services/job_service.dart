import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  static const String _apiKey = 'af3ac268620185067184db7da0306b2b49f874ee';
  static const String _baseUrl = 'https://findwork.dev/api/jobs/';

  /// Fetch jobs from Findwork.dev API
  ///
  /// Parameters:
  /// - [search]: Search query for job titles or keywords
  /// - [location]: Filter by location (e.g., "Remote", "New York")
  /// - [limit]: Number of jobs to return (default 20, max 50)
  Future<List<Job>> fetchJobs({
    String? search,
    String? location,
    int limit = 20,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      // Try to fetch from API
      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Token $_apiKey',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'SkillBridge/1.0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((json) => Job.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please check API key.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to load jobs (${response.statusCode})');
      }
    } catch (e) {
      // If network fails, return mock data for demonstration
      print('Network error, using mock data: $e');
      return _getMockJobs(search: search, location: location, limit: limit);
    }
  }

  /// Mock jobs data for when API is unavailable
  List<Job> _getMockJobs({String? search, String? location, int limit = 20}) {
    final mockJobs = [
      Job(
        id: 1,
        title: 'Senior Flutter Developer',
        companyName: 'TechCorp Solutions',
        location: 'Remote',
        description:
            'We are looking for an experienced Flutter developer to join our mobile team. You will be responsible for developing cross-platform mobile applications with clean code and excellent UI/UX. Requirements: 3+ years Flutter experience, strong Dart knowledge, REST API integration, state management (Provider/Bloc), Git proficiency.',
        employmentType: 'Full-time',
        url:
            'https://www.linkedin.com/jobs/search/?keywords=Senior%20Flutter%20Developer&location=Remote',
        datePosted: DateTime.now().subtract(const Duration(days: 2)),
        remote: 'true',
      ),
      Job(
        id: 2,
        title: 'Mobile App Developer (Flutter)',
        companyName: 'StartupHub Inc',
        location: 'San Francisco, CA',
        description:
            'Join our startup as a Mobile App Developer. Build innovative mobile solutions using Flutter. Work with a dynamic team on cutting-edge projects. Skills needed: Flutter, Firebase, RESTful APIs, Agile methodologies. Benefits include competitive salary, equity, and flexible work hours.',
        employmentType: 'Full-time',
        url:
            'https://www.indeed.com/jobs?q=Flutter+Developer&l=San+Francisco%2C+CA',
        datePosted: DateTime.now().subtract(const Duration(days: 5)),
        remote: 'false',
      ),
      Job(
        id: 3,
        title: 'Junior Flutter Developer',
        companyName: 'Digital Innovations',
        location: 'Remote',
        description:
            'Entry-level position for Flutter developers. Perfect opportunity to grow your skills. Work on real-world projects with mentorship from senior developers. Requirements: Basic Flutter knowledge, understanding of OOP, willingness to learn. We offer training and career development.',
        employmentType: 'Full-time',
        url:
            'https://www.glassdoor.com/Job/junior-flutter-developer-jobs-SRCH_KO0,24.htm',
        datePosted: DateTime.now().subtract(const Duration(hours: 12)),
        remote: 'true',
      ),
      Job(
        id: 4,
        title: 'Flutter Mobile Engineer',
        companyName: 'Global Systems Ltd',
        location: 'New York, NY',
        description:
            'Senior Flutter engineer needed for enterprise mobile applications. Design and implement scalable mobile solutions. Work with cross-functional teams. Required: 5+ years mobile development, Flutter expertise, CI/CD experience, strong problem-solving skills.',
        employmentType: 'Full-time',
        url: 'https://www.indeed.com/jobs?q=Flutter+Engineer&l=New+York%2C+NY',
        datePosted: DateTime.now().subtract(const Duration(days: 1)),
        remote: 'false',
      ),
      Job(
        id: 5,
        title: 'Flutter Developer Intern',
        companyName: 'CodeAcademy Pro',
        location: 'Remote',
        description:
            'Internship opportunity for aspiring Flutter developers. Learn from industry experts while working on real projects. 3-6 month program with potential for full-time conversion. Requirements: Computer Science student or recent graduate, passion for mobile development.',
        employmentType: 'Internship',
        url:
            'https://www.linkedin.com/jobs/search/?keywords=Flutter%20Intern&location=Remote',
        datePosted: DateTime.now().subtract(const Duration(days: 3)),
        remote: 'true',
      ),
      Job(
        id: 6,
        title: 'Lead Flutter Developer',
        companyName: 'Enterprise Tech',
        location: 'London, UK',
        description:
            'Lead our Flutter development team. Architect mobile solutions, mentor junior developers, establish best practices. Requirements: 7+ years development experience, 4+ years Flutter, team leadership experience, excellent communication skills. Competitive package offered.',
        employmentType: 'Full-time',
        url:
            'https://www.linkedin.com/jobs/search/?keywords=Lead%20Flutter%20Developer&location=London',
        datePosted: DateTime.now().subtract(const Duration(days: 7)),
        remote: 'false',
      ),
      Job(
        id: 7,
        title: 'Flutter & React Native Developer',
        companyName: 'Multi-Platform Apps',
        location: 'Remote',
        description:
            'Dual expertise in Flutter and React Native required. Build and maintain cross-platform applications. Work with modern frameworks and tools. Must have: Strong JavaScript/Dart skills, experience with both frameworks, API integration, app deployment experience.',
        employmentType: 'Contract',
        url:
            'https://www.glassdoor.com/Job/flutter-react-native-developer-jobs-SRCH_KO0,30.htm',
        datePosted: DateTime.now().subtract(const Duration(hours: 8)),
        remote: 'true',
      ),
      Job(
        id: 8,
        title: 'Mobile Developer (Flutter Focus)',
        companyName: 'FinTech Innovations',
        location: 'Austin, TX',
        description:
            'Join our FinTech company as a Mobile Developer. Build secure financial applications using Flutter. Work on payment systems, banking apps. Requirements: Flutter experience, understanding of security best practices, financial domain knowledge is a plus.',
        employmentType: 'Full-time',
        url: 'https://www.indeed.com/jobs?q=Flutter+Developer&l=Austin%2C+TX',
        datePosted: DateTime.now().subtract(const Duration(days: 4)),
        remote: 'false',
      ),
      Job(
        id: 9,
        title: 'Flutter UI/UX Developer',
        companyName: 'Creative Apps Studio',
        location: 'Remote',
        description:
            'Combine your Flutter and design skills! Create beautiful, intuitive mobile interfaces. Work closely with designers to implement pixel-perfect UIs. Required: Strong Flutter skills, eye for design, animation experience, portfolio of mobile apps.',
        employmentType: 'Full-time',
        url:
            'https://www.linkedin.com/jobs/search/?keywords=Flutter%20UI%20UX%20Developer&location=Remote',
        datePosted: DateTime.now().subtract(const Duration(days: 6)),
        remote: 'true',
      ),
      Job(
        id: 10,
        title: 'Senior Mobile Architect (Flutter)',
        companyName: 'Cloud Systems Corp',
        location: 'Seattle, WA',
        description:
            'Architect enterprise mobile solutions using Flutter. Define technical strategy, oversee development teams, ensure scalability. Requirements: 8+ years experience, proven architecture skills, cloud integration expertise, leadership abilities. Excellent benefits package.',
        employmentType: 'Full-time',
        url:
            'https://www.indeed.com/jobs?q=Mobile+Architect+Flutter&l=Seattle%2C+WA',
        datePosted: DateTime.now().subtract(const Duration(days: 10)),
        remote: 'false',
      ),
    ];

    // Filter by search if provided
    var filtered = mockJobs;
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(search.toLowerCase()) ||
            job.description.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }

    // Filter by location if provided
    if (location != null && location.isNotEmpty) {
      filtered = filtered.where((job) {
        return job.location.toLowerCase().contains(location.toLowerCase());
      }).toList();
    }

    // Return limited results
    return filtered.take(limit).toList();
  }
}

class Job {
  final int id;
  final String title;
  final String companyName;
  final String location;
  final String description;
  final String employmentType;
  final String url;
  final DateTime datePosted;
  final String? companyLogo;
  final String? remote;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.description,
    required this.employmentType,
    required this.url,
    required this.datePosted,
    this.companyLogo,
    this.remote,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,
      title: json['role'] ?? json['title'] ?? 'Unknown Position',
      companyName: json['company_name'] ?? 'Unknown Company',
      location: json['location'] ?? 'Not specified',
      description: json['text'] ?? json['description'] ?? '',
      employmentType: json['employment_type'] ?? 'Full-time',
      url: json['url'] ?? '',
      datePosted: json['date_posted'] != null
          ? DateTime.parse(json['date_posted'])
          : DateTime.now(),
      companyLogo: json['logo'],
      remote: json['remote']?.toString(),
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(datePosted);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  bool get isRemote {
    return remote == 'true' ||
        location.toLowerCase().contains('remote') ||
        employmentType.toLowerCase().contains('remote');
  }
}
