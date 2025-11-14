import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top greeting card similar to your mock
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good evening, User!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Review your CV analysis',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: () {}, child: const Text('Start now')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("Today's Tasks", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _horizontalCards([
          _FeatureCardData('Update your skills'),
          _FeatureCardData('Industry insights'),
          _FeatureCardData('Networking strategies'),
        ]),
        const SizedBox(height: 16),
        Text('Features', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: const [
            _FeatureTile(title: 'Upload your CV', icon: Icons.upload_file),
            _FeatureTile(
              title: 'Receive tailored insights',
              icon: Icons.insights,
            ),
            _FeatureTile(
              title: 'Track your progress',
              icon: Icons.track_changes,
            ),
            _FeatureTile(title: 'CV checklist', icon: Icons.checklist),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add new'),
          ),
        ),
      ],
    );
  }

  Widget _horizontalCards(List<_FeatureCardData> items) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 160,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  const _FeatureTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}

class _FeatureCardData {
  final String title;
  _FeatureCardData(this.title);
}
