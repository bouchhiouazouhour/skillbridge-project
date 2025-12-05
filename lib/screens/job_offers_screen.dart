import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/job_service.dart';
import 'job_match_screen.dart';

class JobOffersScreen extends StatefulWidget {
  const JobOffersScreen({super.key});

  @override
  State<JobOffersScreen> createState() => _JobOffersScreenState();
}

class _JobOffersScreenState extends State<JobOffersScreen> {
  final JobService _jobService = JobService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<Job> _jobs = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs({String? search, String? location}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await _jobService.fetchJobs(
        search: search,
        location: location,
        limit: 50,
      );
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open job link')),
        );
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _locationController.clear();
        _loadJobs();
      }
    });
  }

  void _performSearch() {
    final search = _searchController.text.trim();
    final location = _locationController.text.trim();
    _loadJobs(
      search: search.isEmpty ? null : search,
      location: location.isEmpty ? null : location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Offers'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                ? _buildErrorState()
                : _jobs.isEmpty
                ? _buildEmptyState()
                : _buildJobList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs (e.g., Flutter, Developer)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.work_outline),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Location (e.g., Remote)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue.shade700),
          const SizedBox(height: 16),
          const Text(
            'Loading job offers...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text(
              'Failed to load jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadJobs(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No jobs found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _toggleSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search Jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return RefreshIndicator(
      onRefresh: () => _loadJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with company logo and remote badge
              Row(
                children: [
                  if (job.companyLogo != null && job.companyLogo!.isNotEmpty)
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(job.companyLogo!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.business, color: Colors.blue.shade700),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.isRemote)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Remote',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Location and job type
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.employmentType,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description preview
              Text(
                job.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer with date and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted ${job.formattedDate}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Row(
                    children: [
                      // Job Match Analyzer button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobMatchScreen(
                                prefilledJobTitle: job.title,
                                prefilledCompanyName: job.companyName,
                                prefilledJobDescription: job.description,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics, size: 16),
                        label: const Text('Analyze'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade700),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Apply button
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(job.url),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Apply'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company and title
                    Row(
                      children: [
                        if (job.companyLogo != null &&
                            job.companyLogo!.isNotEmpty)
                          Container(
                            width: 64,
                            height: 64,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(job.companyLogo!),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 64,
                            height: 64,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.business,
                              size: 32,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.companyName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Job details
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Location',
                      job.location,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.work_outline,
                      'Employment Type',
                      job.employmentType,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Posted',
                      job.formattedDate,
                    ),
                    if (job.isRemote) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.laptop_outlined,
                        'Work Mode',
                        'Remote',
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Job Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons row
                    Row(
                      children: [
                        // Job Match Analyzer button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Close modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobMatchScreen(
                                    prefilledJobTitle: job.title,
                                    prefilledCompanyName: job.companyName,
                                    prefilledJobDescription: job.description,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.analytics),
                            label: const Text('Analyze Match'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              side: BorderSide(color: Colors.blue.shade700),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Apply button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(job.url),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Apply Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
