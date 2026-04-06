import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/data/models/stain_solution.dart';

/// Admin screen to upload stain solutions to Firestore
/// This works because Flutter apps have proper Firebase authentication/permissions
class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const AdminUploadScreen());
  
  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  bool _isUploading = false;
  String _status = '';
  int _successCount = 0;
  int _errorCount = 0;
  final List<String> _errors = [];

  Future<void> _uploadData() async {
    setState(() {
      _isUploading = true;
      _status = '📱 Starting upload...';
      _successCount = 0;
      _errorCount = 0;
      _errors.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection('stain_solutions');

      // Read the JSONL file from project root
      final file = File('Content/stain_solutions.jsonl');
      
      if (!await file.exists()) {
        setState(() {
          _status = '❌ Error: Content/stain_solutions.jsonl not found\n'
              'Make sure you run the app from the project root directory';
          _isUploading = false;
        });
        return;
      }

      setState(() => _status = '📖 Reading stain solutions...');
      
      final lines = await file.readAsLines();
      
      setState(() => _status = 'Found ${lines.length} stain solutions\n\nUploading...');

      // Process each line
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          // Parse JSON
          final json = jsonDecode(line) as Map<String, dynamic>;
          final title = json['title'] as String;
          
          // Create StainSolution object
          final solution = StainSolution.fromJson(json);
          
          // Create a URL-safe ID from the title
          final docId = _createDocId(title);
          
          // Upload to Firestore
          await collection.doc(docId).set(solution.toFirestore());
          
          _successCount++;
          setState(() {
            _status = '✅ [${i + 1}/${lines.length}] Uploaded: $title';
          });
          
        } catch (e) {
          _errorCount++;
          final errorMsg = 'Line ${i + 1}: $e';
          _errors.add(errorMsg);
          setState(() {
            _status = '❌ [${i + 1}/${lines.length}] Error: $errorMsg';
          });
        }
      }

      // Complete
      setState(() {
        _status = '''
✅ Upload Complete!

Successfully uploaded: $_successCount
Errors: $_errorCount

${_errors.isNotEmpty ? '\nErrors:\n${_errors.join('\n')}' : ''}
''';
        _isUploading = false;
      });

    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isUploading = false;
      });
    }
  }

  String _createDocId(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
        .replaceAll(RegExp(r'\s+'), '_')      // Replace spaces with underscores
        .replaceAll(RegExp(r'_+'), '_')       // Replace multiple underscores with single
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Upload Stain Solutions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Stain Solutions to Firestore',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will upload all stain solutions from the JSONL file to Firestore. '
                      'Existing documents with the same ID will be overwritten.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadData,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Start Upload'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _status.isEmpty ? 'Press "Start Upload" to begin' : _status,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

