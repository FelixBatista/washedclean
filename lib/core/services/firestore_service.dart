import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/stain.dart';
import '../data/models/fabric.dart';
import '../data/models/product.dart';
import 'symbol_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stains Collection
  Future<List<Stain>> getStains() async {
    try {
      final snapshot = await _firestore.collection('stains').get();
      return snapshot.docs.map((doc) => Stain.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting stains: $e');
      return [];
    }
  }

  Future<Stain?> getStainById(String id) async {
    try {
      final doc = await _firestore.collection('stains').doc(id).get();
      if (doc.exists) {
        return Stain.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting stain by id: $e');
      return null;
    }
  }

  Future<void> addStain(Stain stain) async {
    try {
      await _firestore.collection('stains').doc(stain.id).set(stain.toFirestore());
    } catch (e) {
      print('Error adding stain: $e');
    }
  }

  Future<void> updateStain(Stain stain) async {
    try {
      await _firestore.collection('stains').doc(stain.id).update(stain.toFirestore());
    } catch (e) {
      print('Error updating stain: $e');
    }
  }

  Future<void> deleteStain(String id) async {
    try {
      await _firestore.collection('stains').doc(id).delete();
    } catch (e) {
      print('Error deleting stain: $e');
    }
  }

  // Fabrics Collection
  Future<List<Fabric>> getFabrics() async {
    try {
      final snapshot = await _firestore.collection('fabrics').get();
      return snapshot.docs.map((doc) => Fabric.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting fabrics: $e');
      return [];
    }
  }

  Future<Fabric?> getFabricById(String id) async {
    try {
      final doc = await _firestore.collection('fabrics').doc(id).get();
      if (doc.exists) {
        return Fabric.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting fabric by id: $e');
      return null;
    }
  }

  Future<void> addFabric(Fabric fabric) async {
    try {
      await _firestore.collection('fabrics').doc(fabric.id).set(fabric.toFirestore());
    } catch (e) {
      print('Error adding fabric: $e');
    }
  }

  Future<void> updateFabric(Fabric fabric) async {
    try {
      await _firestore.collection('fabrics').doc(fabric.id).update(fabric.toFirestore());
    } catch (e) {
      print('Error updating fabric: $e');
    }
  }

  Future<void> deleteFabric(String id) async {
    try {
      await _firestore.collection('fabrics').doc(id).delete();
    } catch (e) {
      print('Error deleting fabric: $e');
    }
  }

  // Products Collection
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product by id: $e');
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toFirestore());
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toFirestore());
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  // Care Symbols Collection
  Future<List<CareSymbol>> getCareSymbols() async {
    try {
      final snapshot = await _firestore.collection('care_symbols').get();
      return snapshot.docs.map((doc) => CareSymbol.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting care symbols: $e');
      return [];
    }
  }

  Future<CareSymbol?> getCareSymbolById(String id) async {
    try {
      final doc = await _firestore.collection('care_symbols').doc(id).get();
      if (doc.exists) {
        return CareSymbol.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting care symbol by id: $e');
      return null;
    }
  }

  Future<void> addCareSymbol(CareSymbol symbol) async {
    try {
      await _firestore.collection('care_symbols').doc(symbol.id).set(symbol.toFirestore());
    } catch (e) {
      print('Error adding care symbol: $e');
    }
  }

  Future<void> updateCareSymbol(CareSymbol symbol) async {
    try {
      await _firestore.collection('care_symbols').doc(symbol.id).update(symbol.toFirestore());
    } catch (e) {
      print('Error updating care symbol: $e');
    }
  }

  Future<void> deleteCareSymbol(String id) async {
    try {
      await _firestore.collection('care_symbols').doc(id).delete();
    } catch (e) {
      print('Error deleting care symbol: $e');
    }
  }

  // Real-time listeners
  Stream<List<Stain>> watchStains() {
    return _firestore.collection('stains').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Stain.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<Fabric>> watchFabrics() {
    return _firestore.collection('fabrics').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Fabric.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<Product>> watchProducts() {
    return _firestore.collection('products').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<CareSymbol>> watchCareSymbols() {
    return _firestore.collection('care_symbols').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => CareSymbol.fromFirestore(doc)).toList(),
    );
  }
}

