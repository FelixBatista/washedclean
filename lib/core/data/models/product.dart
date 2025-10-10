import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.subtitle,
    required this.ingredientsMd,
    required this.howToUseMd,
    this.allergenFlags = const [],
    this.removesStains = const [],
    this.fitsFabrics = const [],
    required this.affiliateUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      subtitle: json['subtitle'] as String,
      ingredientsMd: json['ingredients_md'] as String,
      howToUseMd: json['how_to_use_md'] as String,
      allergenFlags: (json['allergen_flags'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      removesStains: (json['removes_stains'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      fitsFabrics: (json['fits_fabrics'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      affiliateUrl: json['affiliate_url'] as String,
    );
  }

  final String id;
  final String name;
  final String image;
  final String subtitle;
  final String ingredientsMd;
  final String howToUseMd;
  final List<String> allergenFlags;
  final List<String> removesStains;
  final List<String> fitsFabrics;
  final String affiliateUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'subtitle': subtitle,
      'ingredients_md': ingredientsMd,
      'how_to_use_md': howToUseMd,
      'allergen_flags': allergenFlags,
      'removes_stains': removesStains,
      'fits_fabrics': fitsFabrics,
      'affiliate_url': affiliateUrl,
    };
  }

  // Firestore serialization
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}
