class SavedArtwork {
  final String id;
  final String originalImageId;
  final String originalImagePath;

  /// Version 2: paths relative to the documents folder
  /// (`artworks/<id>/image.png`). Version 1 stored absolute paths, which break
  /// when iOS moves the app container on an update.
  final String savedImagePath;
  final String thumbnailPath;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Version 1 only: one colour per pixel index. Version 2 keeps the
  /// drawing in `artworks/<id>/doc.json` instead.
  final Map<String, int> coloredRegions;
  final bool isCompleted;

  /// 1 = per-pixel colours in [coloredRegions], 2 = region document on disk.
  final int schema;

  SavedArtwork({
    required this.id,
    required this.originalImageId,
    required this.originalImagePath,
    required this.savedImagePath,
    required this.thumbnailPath,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.coloredRegions = const {},
    this.isCompleted = false,
    this.schema = 2,
  });

  factory SavedArtwork.fromJson(Map<String, dynamic> json) {
    return SavedArtwork(
      id: json['id'],
      originalImageId: json['originalImageId'],
      originalImagePath: json['originalImagePath'],
      savedImagePath: json['savedImagePath'],
      thumbnailPath: json['thumbnailPath'] ?? '',
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      coloredRegions: Map<String, int>.from(json['coloredRegions'] ?? {}),
      isCompleted: json['isCompleted'] ?? false,
      schema: (json['schema'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalImageId': originalImageId,
      'originalImagePath': originalImagePath,
      'savedImagePath': savedImagePath,
      'thumbnailPath': thumbnailPath,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (coloredRegions.isNotEmpty) 'coloredRegions': coloredRegions,
      'isCompleted': isCompleted,
      'schema': schema,
    };
  }

  SavedArtwork copyWith({
    String? id,
    String? originalImageId,
    String? originalImagePath,
    String? savedImagePath,
    String? thumbnailPath,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? coloredRegions,
    bool? isCompleted,
    int? schema,
  }) {
    return SavedArtwork(
      id: id ?? this.id,
      originalImageId: originalImageId ?? this.originalImageId,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      savedImagePath: savedImagePath ?? this.savedImagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coloredRegions: coloredRegions ?? this.coloredRegions,
      isCompleted: isCompleted ?? this.isCompleted,
      schema: schema ?? this.schema,
    );
  }
}
