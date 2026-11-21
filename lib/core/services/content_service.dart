import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/care_symbol.dart';
import '../data/models/fabric.dart';
import '../data/models/product.dart';
import '../data/models/stain.dart';
import '../data/models/stain_solution.dart';
import 'cloudflare_api_service.dart';

final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService(ref.watch(cloudflareApiServiceProvider));
});

class ContentService {
  ContentService(this._apiService);

  final CloudflareApiService _apiService;

  List<Stain> _stains = [];
  List<Fabric> _fabrics = [];
  List<Product> _products = [];
  List<CareSymbol> _careSymbols = [];
  List<StainSolution> _stainSolutions = [];
  List<Map<String, dynamic>> _articles = [];
  Future<void>? _initialization;

  List<Stain> get stains => _stains;
  List<Fabric> get fabrics => _fabrics;
  List<Product> get products => _products;
  List<CareSymbol> get careSymbols => _careSymbols;
  List<StainSolution> get stainSolutions => _stainSolutions;
  List<Map<String, dynamic>> get articles => _articles;

  Future<void> initialize() => _initialization ??= _loadContent();

  Future<void> _loadContent() async {
    await _loadBundledContent();

    try {
      final items = await _apiService.getContent();
      if (items.isEmpty) {
        throw const CloudflareApiException('The D1 database has no content.');
      }
      _assignContent(items);
      debugPrint('Loaded ${items.length} content records from Cloudflare D1.');
    } catch (error) {
      debugPrint('Cloudflare content is unavailable. Using bundled data: $error');
    }
  }

  void _assignContent(List<Map<String, dynamic>> items) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      final type = item['type'] as String;
      final data = Map<String, dynamic>.from(item['data'] as Map);
      grouped.putIfAbsent(type, () => []).add(data);
    }

    _stains = _recordsOf(grouped, 'stains').map(Stain.fromJson).toList();
    _fabrics = _recordsOf(grouped, 'fabrics').map(Fabric.fromJson).toList();
    _products = _recordsOf(grouped, 'products').map(Product.fromJson).toList();
    _careSymbols = _recordsOf(grouped, 'care_symbols')
        .map(CareSymbol.fromJson)
        .toList();
    _stainSolutions = _recordsOf(grouped, 'stain_solutions')
        .map(StainSolution.fromJson)
        .toList();
    _articles = _recordsOf(grouped, 'articles');
  }

  List<Map<String, dynamic>> _recordsOf(
    Map<String, List<Map<String, dynamic>>> grouped,
    String type,
  ) {
    return grouped[type] ?? const [];
  }

  Future<void> _loadBundledContent() async {
    final stains = await rootBundle.loadString('assets/seed/stains.json');
    _stains = _decodeList(stains).map(Stain.fromJson).toList();

    final fabrics = await rootBundle.loadString('assets/seed/fabrics.json');
    _fabrics = _decodeList(fabrics).map(Fabric.fromJson).toList();

    final products = await rootBundle.loadString('assets/seed/products.json');
    _products = _decodeList(products).map(Product.fromJson).toList();

    final careSymbols = await rootBundle.loadString(
      'assets/seed/care_symbols.json',
    );
    _careSymbols = _decodeList(careSymbols).map(CareSymbol.fromJson).toList();

    final articles = await rootBundle.loadString('assets/seed/articles.json');
    _articles = _decodeList(articles);

    final solutionLines = await rootBundle.loadString(
      'Content/stain_solutions.jsonl',
    );
    _stainSolutions = solutionLines
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .map((solution) => StainSolution.fromJson({
              ...solution,
              'id': solution['id'] ?? _solutionId(solution['title'] as String),
            }))
        .toList();
  }

  List<Map<String, dynamic>> _decodeList(String source) {
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  String _solutionId(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  Stain? getStainById(String id) => _findById(_stains, (item) => item.id, id);

  Fabric? getFabricById(String id) =>
      _findById(_fabrics, (item) => item.id, id);

  Product? getProductById(String id) =>
      _findById(_products, (item) => item.id, id);

  CareSymbol? getCareSymbolById(String id) =>
      _findById(_careSymbols, (item) => item.id, id);

  T? _findById<T>(List<T> records, String Function(T) getId, String id) {
    for (final record in records) {
      if (getId(record) == id) return record;
    }
    return null;
  }
}
