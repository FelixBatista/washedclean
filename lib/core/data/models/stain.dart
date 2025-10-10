import 'package:cloud_firestore/cloud_firestore.dart';

class Stain {
  const Stain({
    required this.id,
    required this.name,
    required this.urgency,
    required this.summary,
    this.byFabric = const [],
    this.relatedProducts = const [],
    this.relatedFabrics = const [],
  });

  factory Stain.fromJson(Map<String, dynamic> json) {
    return Stain(
      id: json['id'] as String,
      name: json['name'] as String,
      urgency: json['urgency'] as String,
      summary: json['summary'] as String,
      byFabric: (json['by_fabric'] as List<dynamic>?)
          ?.map((e) => StainByFabric.fromJson(e))
          .toList() ?? [],
      relatedProducts: (json['related_products'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      relatedFabrics: (json['related_fabrics'] as List<dynamic>?)
          ?.cast<String>() ?? [],
    );
  }

  final String id;
  final String name;
  final String urgency;
  final String summary;
  final List<StainByFabric> byFabric;
  final List<String> relatedProducts;
  final List<String> relatedFabrics;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'urgency': urgency,
      'summary': summary,
      'by_fabric': byFabric.map((e) => e.toJson()).toList(),
      'related_products': relatedProducts,
      'related_fabrics': relatedFabrics,
    };
  }

  // Firestore serialization
  factory Stain.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Stain.fromJson(data);
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

class StainByFabric {
  const StainByFabric({
    required this.fabricId,
    required this.stepsMd,
    this.recommendedProducts = const [],
    this.tipsMd,
    this.ratingUp = 0,
    this.ratingDown = 0,
  });

  factory StainByFabric.fromJson(Map<String, dynamic> json) {
    return StainByFabric(
      fabricId: json['fabric_id'] as String,
      stepsMd: json['steps_md'] as String,
      recommendedProducts: (json['recommended_products'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      tipsMd: json['tips_md'] as String?,
      ratingUp: json['rating_up'] as int? ?? 0,
      ratingDown: json['rating_down'] as int? ?? 0,
    );
  }

  final String fabricId;
  final String stepsMd;
  final List<String> recommendedProducts;
  final String? tipsMd;
  final int ratingUp;
  final int ratingDown;

  Map<String, dynamic> toJson() {
    return {
      'fabric_id': fabricId,
      'steps_md': stepsMd,
      'recommended_products': recommendedProducts,
      'tips_md': tipsMd,
      'rating_up': ratingUp,
      'rating_down': ratingDown,
    };
  }
}
