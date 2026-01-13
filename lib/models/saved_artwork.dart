class SavedArtwork {
  final String id;
  final String originalImageId;
  final String originalImagePath;
  final String savedImagePath;
  final String thumbnailPath;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int> coloredRegions; // regionId -> colorValue
  final bool isCompleted;

  SavedArtwork({
    required this.id,
    required this.originalImageId,
    required this.originalImagePath,
    required this.savedImagePath,
    required this.thumbnailPath,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.coloredRegions,
    this.isCompleted = false,
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
      'coloredRegions': coloredRegions,
      'isCompleted': isCompleted,
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
    );
  }
}
