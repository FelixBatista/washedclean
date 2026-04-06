import 'dart:convert';
import 'dart:io';

/// Pure Dart script to upload stain solutions to Firestore using REST API
/// 
/// Usage: dart lib/scripts/upload_stain_solutions_rest.dart
/// 
/// This script doesn't require Flutter plugins and can run in standalone Dart VM

// Firebase project configuration
const String projectId = 'washedclean-2a45d';
const String firestoreBaseUrl = 'https://firestore.googleapis.com/v1';

Future<void> main() async {
  print('🚀 Starting stain solutions upload to Firestore via REST API...\n');

  // Read the JSONL file
  final file = File('Content/stain_solutions.jsonl');
  
  if (!file.existsSync()) {
    print('❌ Error: Content/stain_solutions.jsonl not found');
    print('   Make sure you\'re running this from the project root directory');
    exit(1);
  }

  print('📖 Reading stain solutions from Content/stain_solutions.jsonl...');
  final lines = await file.readAsLines();
  print('   Found ${lines.length} stain solutions\n');

  int successCount = 0;
  int errorCount = 0;
  final List<String> errors = [];

  // Create HTTP client
  final client = HttpClient();

  try {
    // Process each line
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        // Parse JSON
        final json = jsonDecode(line) as Map<String, dynamic>;
        final title = json['title'] as String;
        
        // Create a URL-safe ID from the title
        final docId = _createDocId(title);
        
        // Upload to Firestore using REST API
        await _uploadDocument(client, docId, json);
        
        successCount++;
        print('✅ [${i + 1}/${lines.length}] Uploaded: $title (ID: $docId)');
        
      } catch (e) {
        errorCount++;
        final errorMsg = 'Line ${i + 1}: $e';
        errors.add(errorMsg);
        print('❌ [${i + 1}/${lines.length}] Error: $errorMsg');
      }
    }
  } finally {
    client.close();
  }

  // Print summary
  print('\n' + '=' * 60);
  print('📊 Upload Summary:');
  print('   ✅ Successfully uploaded: $successCount');
  print('   ❌ Errors: $errorCount');
  
  if (errors.isNotEmpty) {
    print('\n❌ Error Details:');
    for (final error in errors) {
      print('   - $error');
    }
  }
  
  print('=' * 60);
  print('\n🎉 Upload process completed!');
  
  exit(errorCount > 0 ? 1 : 0);
}

/// Upload a document to Firestore using REST API
Future<void> _uploadDocument(
  HttpClient client,
  String docId,
  Map<String, dynamic> data,
) async {
  final url = '$firestoreBaseUrl/projects/$projectId/databases/(default)/documents/stain_solutions?documentId=$docId';
  
  // Convert data to Firestore format
  final firestoreDoc = _convertToFirestoreFormat(data);
  
  final uri = Uri.parse(url);
  final request = await client.postUrl(uri);
  
  // Set headers
  request.headers.set('Content-Type', 'application/json');
  
  // Write body
  final body = jsonEncode({'fields': firestoreDoc});
  request.write(body);
  
  // Get response
  final response = await request.close();
  
  if (response.statusCode != 200 && response.statusCode != 201) {
    final responseBody = await response.transform(utf8.decoder).join();
    throw Exception('Failed to upload document. Status: ${response.statusCode}, Body: $responseBody');
  }
  
  // Drain the response
  await response.drain();
}

/// Convert regular JSON to Firestore REST API format
Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
  final Map<String, dynamic> result = {};
  
  for (final entry in data.entries) {
    result[entry.key] = _convertValue(entry.value);
  }
  
  return result;
}

/// Convert a value to Firestore format
Map<String, dynamic> _convertValue(dynamic value) {
  if (value == null) {
    return {'nullValue': null};
  } else if (value is String) {
    return {'stringValue': value};
  } else if (value is int) {
    return {'integerValue': value.toString()};
  } else if (value is double) {
    return {'doubleValue': value};
  } else if (value is bool) {
    return {'booleanValue': value};
  } else if (value is List) {
    return {
      'arrayValue': {
        'values': value.map((item) => _convertValue(item)).toList(),
      }
    };
  } else if (value is Map) {
    return {
      'mapValue': {
        'fields': _convertToFirestoreFormat(value.cast<String, dynamic>()),
      }
    };
  } else {
    return {'stringValue': value.toString()};
  }
}

/// Creates a URL-safe document ID from a title
String _createDocId(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
      .replaceAll(RegExp(r'\s+'), '_')      // Replace spaces with underscores
      .replaceAll(RegExp(r'_+'), '_')       // Replace multiple underscores with single
      .trim();
}

