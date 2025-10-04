class CareSymbol {
  final String id;
  final String glyph;
  final String title;
  final String explanation;

  const CareSymbol({
    required this.id,
    required this.glyph,
    required this.title,
    required this.explanation,
  });

  factory CareSymbol.fromJson(Map<String, dynamic> json) {
    return CareSymbol(
      id: json['id'] as String,
      glyph: json['glyph'] as String,
      title: json['title'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'glyph': glyph,
      'title': title,
      'explanation': explanation,
    };
  }
}
