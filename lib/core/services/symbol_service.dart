import 'package:hooks_riverpod/hooks_riverpod.dart';

class CareSymbol {
  const CareSymbol({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.fileName,
    required this.isoCode,
    this.temperature,
    this.instructions,
  });

  factory CareSymbol.fromJson(Map<String, dynamic> json) {
    return CareSymbol(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      fileName: json['fileName'] as String,
      isoCode: json['isoCode'] as String,
      temperature: json['temperature'] as int?,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'fileName': fileName,
      'isoCode': isoCode,
      'temperature': temperature,
      'instructions': instructions,
    };
  }
}

enum SymbolCategory {
  washing,
  drying,
  ironing,
  bleaching,
  dryCleaning,
  prohibited,
  temperature,
  specialCare,
}

final symbolServiceProvider = Provider<SymbolService>((ref) {
  return SymbolService();
});

class SymbolService {
  List<CareSymbol> _symbols = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load symbols from the assets directory
      await _loadSymbols();
      _isInitialized = true;
    } catch (e) {
      print('Error loading symbols: $e');
    }
  }

  Future<void> _loadSymbols() async {
    // Create a comprehensive list of symbols based on the available files
    _symbols = [
      // Washing symbols
      const CareSymbol(
        id: 'wash_30',
        name: 'Wash at 30°C',
        description: 'Machine wash at 30°C',
        category: 'washing',
        fileName: 'Waschen_30.svg',
        isoCode: 'ISO 7000-3080',
        temperature: 30,
        instructions: 'Use gentle cycle with cold water',
      ),
      const CareSymbol(
        id: 'wash_40',
        name: 'Wash at 40°C',
        description: 'Machine wash at 40°C',
        category: 'washing',
        fileName: 'Waschen_40.svg',
        isoCode: 'ISO 7000-3081',
        temperature: 40,
        instructions: 'Use normal cycle with warm water',
      ),
      const CareSymbol(
        id: 'wash_50',
        name: 'Wash at 50°C',
        description: 'Machine wash at 50°C',
        category: 'washing',
        fileName: 'Waschen_50.svg',
        isoCode: 'ISO 7000-3085',
        temperature: 50,
        instructions: 'Use normal cycle with hot water',
      ),
      const CareSymbol(
        id: 'wash_60',
        name: 'Wash at 60°C',
        description: 'Machine wash at 60°C',
        category: 'washing',
        fileName: 'Waschen_60.svg',
        isoCode: 'ISO 7000-3086',
        temperature: 60,
        instructions: 'Use normal cycle with hot water',
      ),
      const CareSymbol(
        id: 'wash_70',
        name: 'Wash at 70°C',
        description: 'Machine wash at 70°C',
        category: 'washing',
        fileName: 'Waschen_70.svg',
        isoCode: 'ISO 7000-3087',
        temperature: 70,
        instructions: 'Use normal cycle with very hot water',
      ),
      const CareSymbol(
        id: 'wash_95',
        name: 'Wash at 95°C',
        description: 'Machine wash at 95°C',
        category: 'washing',
        fileName: 'Waschen_95.svg',
        isoCode: 'ISO 7000-3088',
        temperature: 95,
        instructions: 'Use normal cycle with boiling water',
      ),
      const CareSymbol(
        id: 'hand_wash',
        name: 'Hand Wash',
        description: 'Hand wash only',
        category: 'washing',
        fileName: 'Handwäsche.svg',
        isoCode: 'ISO 7000-3089',
        instructions: 'Wash by hand in cold water',
      ),
      const CareSymbol(
        id: 'delicate_wash',
        name: 'Delicate Wash',
        description: 'Gentle machine wash',
        category: 'washing',
        fileName: 'Waschen_schon.svg',
        isoCode: 'ISO 7000-3090',
        instructions: 'Use delicate cycle with gentle agitation',
      ),
      const CareSymbol(
        id: 'no_wash',
        name: 'Do Not Wash',
        description: 'Do not machine wash',
        category: 'prohibited',
        fileName: 'Waschen_nein.svg',
        isoCode: 'ISO 7000-3091',
        instructions: 'Do not wash in machine or by hand',
      ),

      // Drying symbols
      const CareSymbol(
        id: 'tumble_dry',
        name: 'Tumble Dry',
        description: 'Machine tumble dry',
        category: 'drying',
        fileName: 'Trommeltrocknen.svg',
        isoCode: 'ISO 7000-3092',
        instructions: 'Use tumble dryer on normal heat',
      ),
      const CareSymbol(
        id: 'tumble_dry_low',
        name: 'Tumble Dry Low Heat',
        description: 'Machine tumble dry on low heat',
        category: 'drying',
        fileName: 'Trommeltrocknen_1.svg',
        isoCode: 'ISO 7000-3093',
        instructions: 'Use tumble dryer on low heat setting',
      ),
      const CareSymbol(
        id: 'tumble_dry_high',
        name: 'Tumble Dry High Heat',
        description: 'Machine tumble dry on high heat',
        category: 'drying',
        fileName: 'Trommeltrocknen_2.svg',
        isoCode: 'ISO 7000-3094',
        instructions: 'Use tumble dryer on high heat setting',
      ),
      const CareSymbol(
        id: 'no_tumble_dry',
        name: 'Do Not Tumble Dry',
        description: 'Do not tumble dry',
        category: 'prohibited',
        fileName: 'Nicht_trommeltrocknen.svg',
        isoCode: 'ISO 7000-3095',
        instructions: 'Do not use tumble dryer',
      ),
      const CareSymbol(
        id: 'line_dry',
        name: 'Line Dry',
        description: 'Hang to dry',
        category: 'drying',
        fileName: 'Trocknen_(hang).svg',
        isoCode: 'ISO 7000-3096',
        instructions: 'Hang to dry naturally',
      ),
      const CareSymbol(
        id: 'line_dry_shade',
        name: 'Line Dry in Shade',
        description: 'Hang to dry in shade',
        category: 'drying',
        fileName: 'Trocknen_(hang_in_shade).svg',
        isoCode: 'ISO 7000-3097',
        instructions: 'Hang to dry in shade to prevent fading',
      ),
      const CareSymbol(
        id: 'flat_dry',
        name: 'Flat Dry',
        description: 'Lay flat to dry',
        category: 'drying',
        fileName: 'Trocknen_(liegend).svg',
        isoCode: 'ISO 7000-3098',
        instructions: 'Lay flat to dry to maintain shape',
      ),

      // Ironing symbols
      const CareSymbol(
        id: 'iron',
        name: 'Iron',
        description: 'Iron at any temperature',
        category: 'ironing',
        fileName: 'Bügeln.svg',
        isoCode: 'ISO 7000-3099',
        instructions: 'Iron at any temperature',
      ),
      const CareSymbol(
        id: 'iron_low',
        name: 'Iron Low Heat',
        description: 'Iron at low temperature',
        category: 'ironing',
        fileName: 'Bügeln_1.svg',
        isoCode: 'ISO 7000-3100A',
        instructions: 'Iron at low temperature (max 110°C)',
      ),
      const CareSymbol(
        id: 'iron_medium',
        name: 'Iron Medium Heat',
        description: 'Iron at medium temperature',
        category: 'ironing',
        fileName: 'Bügeln_2.svg',
        isoCode: 'ISO 7000-3100B',
        instructions: 'Iron at medium temperature (max 150°C)',
      ),
      const CareSymbol(
        id: 'iron_high',
        name: 'Iron High Heat',
        description: 'Iron at high temperature',
        category: 'ironing',
        fileName: 'Bügeln_3.svg',
        isoCode: 'ISO 7000-3101',
        instructions: 'Iron at high temperature (max 200°C)',
      ),
      const CareSymbol(
        id: 'no_iron',
        name: 'Do Not Iron',
        description: 'Do not iron',
        category: 'prohibited',
        fileName: 'Nicht_bügeln.svg',
        isoCode: 'ISO 7000-3102',
        instructions: 'Do not iron or use steam',
      ),
      const CareSymbol(
        id: 'iron_no_steam',
        name: 'Iron Without Steam',
        description: 'Iron without steam',
        category: 'ironing',
        fileName: 'Ironing_without_steam_(ISO_7000).svg',
        isoCode: 'ISO 7000-3103A',
        instructions: 'Iron without steam',
      ),
      const CareSymbol(
        id: 'iron_with_steam',
        name: 'Iron With Steam',
        description: 'Iron with steam',
        category: 'ironing',
        fileName: 'Ironing_with_moisture_(ISO_7000).svg',
        isoCode: 'ISO 7000-3103B',
        instructions: 'Iron with steam allowed',
      ),

      // Bleaching symbols
      const CareSymbol(
        id: 'bleach',
        name: 'Bleach',
        description: 'Bleach allowed',
        category: 'bleaching',
        fileName: 'Bleichen.svg',
        isoCode: 'ISO 7000-3104A',
        instructions: 'Bleach with chlorine or oxygen bleach',
      ),
      const CareSymbol(
        id: 'bleach_oxygen',
        name: 'Oxygen Bleach Only',
        description: 'Oxygen bleach only',
        category: 'bleaching',
        fileName: 'Sauerstoffbleichen.svg',
        isoCode: 'ISO 7000-3104B',
        instructions: 'Use oxygen bleach only, no chlorine',
      ),
      const CareSymbol(
        id: 'no_bleach',
        name: 'Do Not Bleach',
        description: 'Do not bleach',
        category: 'prohibited',
        fileName: 'Nicht_bleichen.svg',
        isoCode: 'ISO 7000-3105A',
        instructions: 'Do not use any type of bleach',
      ),

      // Dry cleaning symbols
      const CareSymbol(
        id: 'dry_clean',
        name: 'Dry Clean',
        description: 'Dry clean only',
        category: 'dryCleaning',
        fileName: 'Professionelle_reinigung.svg',
        isoCode: 'ISO 7000-3106A',
        instructions: 'Professional dry cleaning only',
      ),
      const CareSymbol(
        id: 'dry_clean_p',
        name: 'Dry Clean (P)',
        description: 'Dry clean with P solvent',
        category: 'dryCleaning',
        fileName: 'Professionelle_reinigung_(P).svg',
        isoCode: 'ISO 7000-3106B',
        instructions: 'Dry clean with perchloroethylene',
      ),
      const CareSymbol(
        id: 'dry_clean_f',
        name: 'Dry Clean (F)',
        description: 'Dry clean with F solvent',
        category: 'dryCleaning',
        fileName: 'Professionelle_reinigung_(F).svg',
        isoCode: 'ISO 7000-3107',
        instructions: 'Dry clean with petroleum solvent',
      ),
      const CareSymbol(
        id: 'no_dry_clean',
        name: 'Do Not Dry Clean',
        description: 'Do not dry clean',
        category: 'prohibited',
        fileName: 'Nicht_chemisch_reinigen.svg',
        isoCode: 'ISO 7000-3108',
        instructions: 'Do not dry clean',
      ),

      // Wet cleaning symbols
      const CareSymbol(
        id: 'wet_clean',
        name: 'Wet Clean',
        description: 'Professional wet cleaning',
        category: 'dryCleaning',
        fileName: 'Professionelle_reinigung_(W).svg',
        isoCode: 'ISO 7000-3109',
        instructions: 'Professional wet cleaning only',
      ),
      const CareSymbol(
        id: 'no_wet_clean',
        name: 'Do Not Wet Clean',
        description: 'Do not wet clean',
        category: 'prohibited',
        fileName: 'Nicht_nassreinigen.svg',
        isoCode: 'ISO 7000-3110',
        instructions: 'Do not use professional wet cleaning',
      ),
    ];
  }

  List<CareSymbol> get symbols => _symbols;
  List<CareSymbol> get washingSymbols => _symbols.where((s) => s.category == 'washing').toList();
  List<CareSymbol> get dryingSymbols => _symbols.where((s) => s.category == 'drying').toList();
  List<CareSymbol> get ironingSymbols => _symbols.where((s) => s.category == 'ironing').toList();
  List<CareSymbol> get bleachingSymbols => _symbols.where((s) => s.category == 'bleaching').toList();
  List<CareSymbol> get dryCleaningSymbols => _symbols.where((s) => s.category == 'dryCleaning').toList();
  List<CareSymbol> get prohibitedSymbols => _symbols.where((s) => s.category == 'prohibited').toList();

  List<CareSymbol> getSymbolsByCategory(String category) {
    return _symbols.where((s) => s.category == category).toList();
  }

  CareSymbol? getSymbolById(String id) {
    try {
      return _symbols.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CareSymbol> searchSymbols(String query) {
    if (query.trim().isEmpty) return _symbols;
    
    final normalizedQuery = query.toLowerCase().trim();
    return _symbols.where((symbol) {
      return symbol.name.toLowerCase().contains(normalizedQuery) ||
             symbol.description.toLowerCase().contains(normalizedQuery) ||
             symbol.instructions?.toLowerCase().contains(normalizedQuery) == true;
    }).toList();
  }

  List<String> get categories => [
    'washing',
    'drying', 
    'ironing',
    'bleaching',
    'dryCleaning',
    'prohibited',
  ];

  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'washing':
        return 'Washing';
      case 'drying':
        return 'Drying';
      case 'ironing':
        return 'Ironing';
      case 'bleaching':
        return 'Bleaching';
      case 'dryCleaning':
        return 'Dry Cleaning';
      case 'prohibited':
        return 'Prohibited';
      default:
        return category;
    }
  }
}
