import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/app_config.dart';
import '../../providers/user_provider.dart';

class OptimizeScreen extends StatefulWidget {
  const OptimizeScreen({super.key});

  @override
  State<OptimizeScreen> createState() => _OptimizeScreenState();
}

class _OptimizeScreenState extends State<OptimizeScreen> {
  PlatformFile? _pickedFile;
  bool _loading = false;
  Map<String, dynamic>? _analysis;
  String? _error;

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'docx'],
      withData: true,
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
      final token = context.read<UserProvider>().token;
      if (token == null) {
        setState(() => _error = 'Not authenticated.');
        return;
      }
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/cv/analyze');
      final req = http.MultipartRequest('POST', uri);
      req.headers['Authorization'] = 'Bearer $token';
      req.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );

      final streamed = await req.send();
      final respBody = await streamed.stream.bytesToString();
      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        final jsonData = json.decode(respBody) as Map<String, dynamic>;
        final data = jsonData['data'] as Map<String, dynamic>;
        setState(() => _analysis = data);
      } else if (streamed.statusCode == 401) {
        setState(() => _error = 'Unauthorized. Please log in again.');
      } else {
        setState(
          () => _error = 'Upload failed (${streamed.statusCode}): $respBody',
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optimize your CV')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                      ((_analysis!['suggestions'] as List<dynamic>)).map(
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
      ),
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
  final double value;
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
