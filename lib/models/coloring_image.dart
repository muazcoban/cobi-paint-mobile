class ColoringImage {
  final String id;
  final String name;
  final String category;
  final String imagePath;
  final bool isFromFirebase;
  final bool isImported;
  final DateTime? createdAt;

  ColoringImage({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    this.isFromFirebase = false,
    this.isImported = false,
    this.createdAt,
  });

  factory ColoringImage.fromJson(Map<String, dynamic> json) {
    return ColoringImage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      imagePath: json['imagePath'] ?? '',
      isFromFirebase: json['isFromFirebase'] ?? false,
      isImported: json['isImported'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'isFromFirebase': isFromFirebase,
      'isImported': isImported,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  ColoringImage copyWith({
    String? id,
    String? name,
    String? category,
    String? imagePath,
    bool? isFromFirebase,
    bool? isImported,
    DateTime? createdAt,
  }) {
    return ColoringImage(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      isFromFirebase: isFromFirebase ?? this.isFromFirebase,
      isImported: isImported ?? this.isImported,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
