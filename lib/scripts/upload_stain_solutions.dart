import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/data/models/stain_solution.dart';

/// Script to upload stain solutions from the JSONL file to Firestore
/// 
/// Usage: dart run lib/scripts/upload_stain_solutions.dart
/// 
/// This will read Content/stain_solutions.jsonl and upload each entry to Firestore

Future<void> main() async {
  print('🚀 Starting stain solutions upload to Firestore...\n');

  // Initialize Firebase
  print('📱 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized\n');

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('stain_solutions');

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
      
      successCount++;
      print('✅ [${i + 1}/${lines.length}] Uploaded: $title (ID: $docId)');
      
    } catch (e) {
      errorCount++;
      final errorMsg = 'Line ${i + 1}: $e';
      errors.add(errorMsg);
      print('❌ [${i + 1}/${lines.length}] Error: $errorMsg');
    }
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

/// Creates a URL-safe document ID from a title
String _createDocId(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
      .replaceAll(RegExp(r'\s+'), '_')      // Replace spaces with underscores
      .replaceAll(RegExp(r'_+'), '_')       // Replace multiple underscores with single
      .trim();
}

