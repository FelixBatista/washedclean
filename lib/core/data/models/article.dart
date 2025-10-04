class Article {
  const Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.bodyMd,
    this.cta,
    this.tags = const [],
    this.featured = false,
    this.lang = 'en',
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      image: json['image'] as String,
      bodyMd: json['body_md'] as String,
      cta: json['cta'] != null ? CtaButton.fromJson(json['cta']) : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      featured: json['featured'] as bool? ?? false,
      lang: json['lang'] as String? ?? 'en',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String bodyMd;
  final CtaButton? cta;
  final List<String> tags;
  final bool featured;
  final String lang;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'body_md': bodyMd,
      'cta': cta?.toJson(),
      'tags': tags,
      'featured': featured,
      'lang': lang,
    };
  }
}

class CtaButton {
  const CtaButton({
    required this.label,
    required this.route,
  });

  factory CtaButton.fromJson(Map<String, dynamic> json) {
    return CtaButton(
      label: json['label'] as String,
      route: json['route'] as String,
    );
  }

  final String label;
  final String route;

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'route': route,
    };
  }
}
