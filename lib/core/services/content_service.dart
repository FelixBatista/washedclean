import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/article.dart';
import '../data/models/stain.dart';
import '../data/models/fabric.dart';
import '../data/models/product.dart';
import '../data/models/care_symbol.dart';

final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService();
});

class ContentService {
  List<Article> _articles = [];
  List<Stain> _stains = [];
  List<Fabric> _fabrics = [];
  List<Product> _products = [];
  List<CareSymbol> _careSymbols = [];

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load articles
      final articlesJson = await rootBundle.loadString('assets/seed/articles.json');
      final articlesList = json.decode(articlesJson) as List;
      _articles = articlesList.map((json) => Article.fromJson(json)).toList();

      // Load stains
      final stainsJson = await rootBundle.loadString('assets/seed/stains.json');
      final stainsList = json.decode(stainsJson) as List;
      _stains = stainsList.map((json) => Stain.fromJson(json)).toList();

      // Load fabrics
      final fabricsJson = await rootBundle.loadString('assets/seed/fabrics.json');
      final fabricsList = json.decode(fabricsJson) as List;
      _fabrics = fabricsList.map((json) => Fabric.fromJson(json)).toList();

      // Load products
      final productsJson = await rootBundle.loadString('assets/seed/products.json');
      final productsList = json.decode(productsJson) as List;
      _products = productsList.map((json) => Product.fromJson(json)).toList();

      // Load care symbols
      final symbolsJson = await rootBundle.loadString('assets/seed/care_symbols.json');
      final symbolsList = json.decode(symbolsJson) as List;
      _careSymbols = symbolsList.map((json) => CareSymbol.fromJson(json)).toList();

      _isInitialized = true;
    } catch (e) {
      // Handle error - could load from fallback or show error
      print('Error loading content: $e');
    }
  }

  List<Article> get articles => _articles;
  List<Stain> get stains => _stains;
  List<Fabric> get fabrics => _fabrics;
  List<Product> get products => _products;
  List<CareSymbol> get careSymbols => _careSymbols;

  List<Article> get featuredArticles => _articles.where((a) => a.featured).toList();

  Article? getArticleById(String id) {
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Stain? getStainById(String id) {
    try {
      return _stains.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Fabric? getFabricById(String id) {
    try {
      return _fabrics.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  CareSymbol? getCareSymbolById(String id) {
    try {
      return _careSymbols.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
