import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(radius: 36, child: Text('AM')), // placeholder avatar
        const SizedBox(height: 12),
        Text('Alex Morgan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'alex.morgan@example.com',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(label: 'CVs uploaded', value: '5'),
            _StatCard(label: 'Insights', value: '12'),
            _StatCard(label: 'Jobs applied', value: '24'),
            _StatCard(label: 'Saved CVs', value: '15'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Key Skills', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _SkillBar(label: 'Experience', value: 0.75),
        _SkillBar(label: 'Education', value: 0.65),
        _SkillBar(label: 'Certifications', value: 0.40),
        _SkillBar(label: 'Languages', value: 0.55),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  const _SkillBar({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(minHeight: 12, value: value),
          ),
        ],
      ),
    );
  }
}
