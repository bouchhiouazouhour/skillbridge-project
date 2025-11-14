import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../services/service_locator.dart';

/// Screen allowing user to pick a CV file and send it to backend for analysis.
class OptimizeScreen extends StatefulWidget {
  const OptimizeScreen({super.key});

  @override
  State<OptimizeScreen> createState() => _OptimizeScreenState();
}

class _OptimizeScreenState extends State<OptimizeScreen> {
  PlatformFile? _pickedFile;
  bool _loading = false;
  Map<String, dynamic>? _analysis; // { sub_scores: {}, suggestions: [] }
  String? _error;

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      withData: true, // we will upload from memory
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _pickedFile = res.files.first);
    }
  }

  Future<void> _submit() async {
    if (_pickedFile == null) {
      setState(() => _error = 'Please select a CV file first.');
      return;
    }
    final file = _pickedFile!;
    if (file.bytes == null) {
      setState(() => _error = 'Unable to read file data.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _analysis = null;
    });
    try {
      // Access global ApiClient via context ancestor (MyApp sets instances in main.dart).
      // We stored them as top-level late finals: _apiClient & _authService.
      // Importing isn't possible directly; instead rely on InheritedWidget pattern eventually.
      // For now, recreate small handle by using a global function.
      final apiClient = ServiceLocator.apiClient;
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final resp = await apiClient.post('/cv/analyze', data: form);
      final data = resp.data['data'] as Map<String, dynamic>;
      setState(() => _analysis = data);
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?.toString() ?? e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // (No extra helpers needed.)

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Optimize Your CV',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                _pickedFile == null ? 'No file selected' : _pickedFile!.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit for Analysis'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        if (_analysis != null) ...[
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Results',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _ScoresTable(
                    subScores: Map<String, dynamic>.from(
                      _analysis!['sub_scores'] as Map,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Suggestions',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  ...List<Widget>.from(
                    (_analysis!['suggestions'] as List<dynamic>).map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Expanded(child: Text(s.toString())),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoresTable extends StatelessWidget {
  final Map<String, dynamic> subScores;
  const _ScoresTable({required this.subScores});
  @override
  Widget build(BuildContext context) {
    final entries = subScores.entries.toList();
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(child: Text(e.key)),
                _ScoreBar(value: (e.value as num).toDouble()),
                const SizedBox(width: 8),
                Text('${(e.value as num) * 100 ~/ 1}%'),
              ],
            ),
          ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double value; // 0..1
  const _ScoreBar({required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: value),
      ),
    );
  }
}

// (No extra helpers needed.)
