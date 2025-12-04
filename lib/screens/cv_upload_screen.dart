import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class CVUploadScreen extends StatefulWidget {
  const CVUploadScreen({super.key});

  @override
  State<CVUploadScreen> createState() => _CVUploadScreenState();
}

class _CVUploadScreenState extends State<CVUploadScreen> {
  final _apiService = ApiService();
  File? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadCV() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      final response = await _apiService.uploadCV(_selectedFile!);
      final cvId = response['cv']['id'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to results screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(cvId: cvId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimize Your CV'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Icon(
              Icons.description,
              size: 100,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Upload Your CV',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'We support PDF and DOCX formats',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // File selection card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.blue.shade700,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: _isUploading ? null : _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile == null
                            ? Icons.cloud_upload
                            : Icons.check_circle,
                        size: 64,
                        color: _selectedFile == null
                            ? Colors.blue.shade700
                            : Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFile == null
                            ? 'Tap to select file'
                            : 'File selected:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Upload progress
            if (_isUploading) ...[
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Uploading... ${(_uploadProgress * 100).toInt()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
            // Upload button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadCV,
                icon: const Icon(Icons.upload),
                label: const Text(
                  'Upload & Analyze',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Info section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'What we analyze:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem('✓ Skills and keywords'),
                    _buildInfoItem('✓ Missing sections'),
                    _buildInfoItem('✓ ATS compatibility'),
                    _buildInfoItem('✓ Improvement suggestions'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
