class CareSymbol {
  const CareSymbol({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'specialCare',
    this.fileName = 'Textilpflegesymbole.svg',
    this.isoCode = '',
    this.temperature,
    this.instructions,
  });

  factory CareSymbol.fromJson(Map<String, dynamic> json) {
    return CareSymbol(
      id: json['id'] as String,
      name: (json['name'] ?? json['title']) as String,
      description: (json['description'] ?? json['explanation']) as String,
      category: (json['category'] as String?) ?? _categoryForId(json['id'] as String),
      fileName: _fileNameFor(json),
      isoCode: (json['iso_code'] ?? json['isoCode'] ?? '') as String,
      temperature: (json['temperature'] as num?)?.toInt(),
      instructions: json['instructions'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String category;
  final String fileName;
  final String isoCode;
  final int? temperature;
  final String? instructions;

  String get assetPath => 'assets/symbols/$fileName';
  String get title => name;
  String get explanation => description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'file_name': fileName,
      'iso_code': isoCode,
      'temperature': temperature,
      'instructions': instructions,
    };
  }

  static String _fileNameFor(Map<String, dynamic> json) {
    final knownFiles = <String, String>{
      'wash_30': 'Waschen_30.svg',
      'wash_40': 'Waschen_40.svg',
      'wash_60': 'Waschen_60.svg',
      'wash_95': 'Waschen_95.svg',
      'hand_wash': 'Handwäsche.svg',
      'do_not_wash': 'Nicht_waschen.svg',
      'bleach_ok': 'Bleichen.svg',
      'bleach_no': 'Nicht_bleichen.svg',
      'tumble_dry_low': 'Trockner_wenig_Temperatur.svg',
      'tumble_dry_medium': 'Trommeltrocknen_1.svg',
      'tumble_dry_high': 'Trommeltrocknen_2.svg',
      'do_not_tumble_dry': 'Nicht_trommeltrocknen.svg',
      'iron_low': 'Bügeln_1.svg',
      'iron_medium': 'Bügeln_2.svg',
      'iron_high': 'Bügeln_3.svg',
      'do_not_iron': 'Nicht_bügeln.svg',
      'dry_clean': 'Professionelle_reinigung.svg',
      'dry_clean_p': 'Professionelle_reinigung_(P).svg',
      'do_not_dry_clean': 'Nicht_chemisch_reinigen.svg',
    };
    final id = json['id'] as String;
    if (knownFiles.containsKey(id)) return knownFiles[id]!;

    final suppliedPath = (json['file_name'] ?? json['fileName'] ?? json['glyph']) as String?;
    if (suppliedPath == null) return 'Textilpflegesymbole.svg';
    return suppliedPath.split('/').last;
  }

  static String _categoryForId(String id) {
    if (id.startsWith('wash_') || id == 'hand_wash') return 'washing';
    if (id.startsWith('tumble_dry_') || id == 'do_not_tumble_dry') {
      return 'drying';
    }
    if (id.startsWith('iron_') || id == 'do_not_iron') return 'ironing';
    if (id.startsWith('bleach_')) return 'bleaching';
    if (id.startsWith('dry_clean')) return 'dryCleaning';
    if (id.startsWith('do_not_')) return 'prohibited';
    return 'specialCare';
  }
}
