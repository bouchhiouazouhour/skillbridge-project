import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NetworkingStrategiesScreen extends StatelessWidget {
  const NetworkingStrategiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Networking Strategies'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Card(
                elevation: 2,
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 40,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expand Your Network',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build meaningful professional connections',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Introduction
              const Text(
                'Why Networking Matters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Professional networking is essential for career growth. It opens doors to new opportunities, helps you learn from others, and builds your reputation in your industry.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Strategies Section
              const Text(
                'Effective Strategies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildStrategyCard(
                icon: Icons.handshake,
                title: 'Attend Industry Events',
                description:
                    'Join conferences, workshops, and meetups in your field. These are great opportunities to meet like-minded professionals.',
                color: Colors.blue,
                tips: [
                  'Prepare your elevator pitch',
                  'Bring business cards',
                  'Follow up within 24-48 hours',
                  'Be genuinely interested in others',
                ],
              ),
              const SizedBox(height: 16),

              _buildStrategyCard(
                icon: Icons.computer,
                title: 'Leverage LinkedIn',
                description:
                    'Optimize your LinkedIn profile and actively engage with your network.',
                color: Colors.indigo,
                tips: [
                  'Post valuable content regularly',
                  'Comment thoughtfully on others\' posts',
                  'Send personalized connection requests',
                  'Join relevant LinkedIn groups',
                ],
              ),
              const SizedBox(height: 16),

              _buildStrategyCard(
                icon: Icons.coffee,
                title: 'Coffee Chats',
                description:
                    'Reach out to people for informal one-on-one conversations.',
                color: Colors.brown,
                tips: [
                  'Ask for 20-30 minutes of their time',
                  'Come prepared with questions',
                  'Show appreciation for their time',
                  'Offer help when possible',
                ],
              ),
              const SizedBox(height: 16),

              _buildStrategyCard(
                icon: Icons.school,
                title: 'Alumni Networks',
                description:
                    'Connect with fellow alumni from your school or university.',
                color: Colors.purple,
                tips: [
                  'Join alumni associations',
                  'Attend reunion events',
                  'Reach out with shared experiences',
                  'Offer mentorship to younger alumni',
                ],
              ),
              const SizedBox(height: 16),

              _buildStrategyCard(
                icon: Icons.volunteer_activism,
                title: 'Give Back',
                description:
                    'Help others without expecting anything in return.',
                color: Colors.orange,
                tips: [
                  'Mentor junior professionals',
                  'Share your knowledge through blogs',
                  'Make introductions between contacts',
                  'Volunteer in professional organizations',
                ],
              ),
              const SizedBox(height: 24),

              // Key Principles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Key Principles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPrinciple('Be authentic and genuine'),
                    _buildPrinciple(
                      'Focus on building relationships, not just contacts',
                    ),
                    _buildPrinciple('Stay in touch regularly'),
                    _buildPrinciple('Always add value to your connections'),
                    _buildPrinciple('Quality over quantity'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://www.linkedin.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open LinkedIn'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Start Networking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
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
        ),
      ),
    );
  }

  Widget _buildStrategyCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<String> tips,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, size: 18, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinciple(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
