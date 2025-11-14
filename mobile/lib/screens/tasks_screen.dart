import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      ('Profile Optimizer', 0.6),
      ('Job Hunter', 0.3),
      ('Feedback Master', 0.8),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Activity Log', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final t in tasks)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$1, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: t.$2),
                  const SizedBox(height: 4),
                  Text('${(t.$2 * 100).round()}% complete'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
