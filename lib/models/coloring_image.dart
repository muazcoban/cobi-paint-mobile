class ColoringImage {
  final String id;

  /// Turkish name; [nameEn] is the English one. Spoken, never shown to the child.
  final String name;
  final String nameEn;
  final String category;
  final String imagePath;

  /// Difficulty from the page check: 1 = a few big areas, 2 = more areas,
  /// 3 = fine detail. Pages are never locked; the level only orders them.
  final int level;

  /// A blank or background page for free drawing: the marker is not kept
  /// inside a region, the eraser only clears strokes, and every tap on its
  /// card starts a new picture.
  final bool freeDraw;

  /// Part of the fixed free subset shown before the Full Version is bought.
  final bool free;
  final bool isImported;
  final DateTime? createdAt;

  const ColoringImage({
    required this.id,
    required this.name,
    this.nameEn = '',
    required this.category,
    required this.imagePath,
    this.level = 2,
    this.freeDraw = false,
    this.free = false,
    this.isImported = false,
    this.createdAt,
  });

  factory ColoringImage.fromJson(Map<String, dynamic> json) {
    return ColoringImage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      category: json['category'] ?? '',
      imagePath: json['imagePath'] ?? '',
      level: (json['level'] as num?)?.toInt() ?? 2,
      freeDraw: json['freeDraw'] ?? false,
      free: json['free'] ?? false,
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
      'nameEn': nameEn,
      'category': category,
      'imagePath': imagePath,
      'level': level,
      'freeDraw': freeDraw,
      'free': free,
      'isImported': isImported,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// The name in the app's language.
  String localizedName(String languageCode) =>
      languageCode.startsWith('tr') || nameEn.isEmpty ? name : nameEn;

  ColoringImage copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? category,
    String? imagePath,
    int? level,
    bool? freeDraw,
    bool? free,
    bool? isImported,
    DateTime? createdAt,
  }) {
    return ColoringImage(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      level: level ?? this.level,
      freeDraw: freeDraw ?? this.freeDraw,
      free: free ?? this.free,
      isImported: isImported ?? this.isImported,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
