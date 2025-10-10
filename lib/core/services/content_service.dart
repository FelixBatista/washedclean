import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/stain.dart';
import '../data/models/fabric.dart';
import '../data/models/product.dart';
import 'firestore_service.dart';
import 'symbol_service.dart';

final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService(ref.watch(firestoreServiceProvider));
});

class ContentService {
  final FirestoreService _firestoreService;
  
  ContentService(this._firestoreService);
  
  List<Stain> _stains = [];
  List<Fabric> _fabrics = [];
  List<Product> _products = [];
  List<CareSymbol> _careSymbols = [];

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load data from Firestore
      _stains = await _firestoreService.getStains();
      _fabrics = await _firestoreService.getFabrics();
      _products = await _firestoreService.getProducts();
      _careSymbols = await _firestoreService.getCareSymbols();
      
      _isInitialized = true;
    } catch (e) {
      print('Error loading data from Firestore: $e');
      // Fallback to local data if Firestore fails
      await _loadLocalData();
      _isInitialized = true;
    }
  }

  Future<void> _loadLocalData() async {
    try {
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
    } catch (e) {
      print('Error loading local data: $e');
    }
  }

  List<Stain> get stains => _stains;
  List<Fabric> get fabrics => _fabrics;
  List<Product> get products => _products;
  List<CareSymbol> get careSymbols => _careSymbols;

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
