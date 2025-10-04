class Fabric {
  const Fabric({
    required this.id,
    required this.name,
    required this.image,
    required this.overviewMd,
    required this.stepsMd,
    this.commonStains = const [],
    this.recommendedProducts = const [],
  });

  factory Fabric.fromJson(Map<String, dynamic> json) {
    return Fabric(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      overviewMd: json['overview_md'] as String,
      stepsMd: json['steps_md'] as String,
      commonStains: (json['common_stains'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      recommendedProducts: (json['recommended_products'] as List<dynamic>?)
          ?.cast<String>() ?? [],
    );
  }

  final String id;
  final String name;
  final String image;
  final String overviewMd;
  final String stepsMd;
  final List<String> commonStains;
  final List<String> recommendedProducts;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'overview_md': overviewMd,
      'steps_md': stepsMd,
      'common_stains': commonStains,
      'recommended_products': recommendedProducts,
    };
  }
}
