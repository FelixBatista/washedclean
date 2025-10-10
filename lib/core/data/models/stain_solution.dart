import 'package:cloud_firestore/cloud_firestore.dart';

class StainSolution {
  const StainSolution({
    required this.id,
    required this.title,
    required this.introNotes,
    required this.sections,
    this.cautions = const [],
    this.extra = const [],
    this.sourceArchiveUrl,
    this.sourceOriginalUrl,
  });

  factory StainSolution.fromJson(Map<String, dynamic> json) {
    return StainSolution(
      id: json['id'] as String? ?? json['title'] as String,
      title: json['title'] as String,
      introNotes: (json['intro_notes'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      sections: (json['sections'] as List<dynamic>?)
          ?.map((e) => SolutionSection.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      cautions: (json['cautions'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      extra: (json['extra'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      sourceArchiveUrl: json['source_archive_url'] as String?,
      sourceOriginalUrl: json['source_original_url'] as String?,
    );
  }

  final String id;
  final String title;
  final List<String> introNotes;
  final List<SolutionSection> sections;
  final List<String> cautions;
  final List<String> extra;
  final String? sourceArchiveUrl;
  final String? sourceOriginalUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'intro_notes': introNotes,
      'sections': sections.map((e) => e.toJson()).toList(),
      'cautions': cautions,
      'extra': extra,
      'source_archive_url': sourceArchiveUrl,
      'source_original_url': sourceOriginalUrl,
    };
  }

  // Firestore serialization
  factory StainSolution.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StainSolution.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

class SolutionSection {
  const SolutionSection({
    required this.sectionName,
    required this.methods,
  });

  factory SolutionSection.fromJson(Map<String, dynamic> json) {
    return SolutionSection(
      sectionName: json['section_name'] as String,
      methods: (json['methods'] as List<dynamic>?)
          ?.map((e) => SolutionMethod.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  final String sectionName;
  final List<SolutionMethod> methods;

  Map<String, dynamic> toJson() {
    return {
      'section_name': sectionName,
      'methods': methods.map((e) => e.toJson()).toList(),
    };
  }
}

class SolutionMethod {
  const SolutionMethod({
    this.materials = const [],
    this.steps = const [],
    this.notes = const [],
    this.cautions = const [],
    this.extra = '',
  });

  factory SolutionMethod.fromJson(Map<String, dynamic> json) {
    return SolutionMethod(
      materials: (json['materials'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      steps: (json['steps'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      notes: (json['notes'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      cautions: (json['cautions'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      extra: json['extra'] as String? ?? '',
    );
  }

  final List<String> materials;
  final List<String> steps;
  final List<String> notes;
  final List<String> cautions;
  final String extra;

  Map<String, dynamic> toJson() {
    return {
      'materials': materials,
      'steps': steps,
      'notes': notes,
      'cautions': cautions,
      'extra': extra,
    };
  }
}

