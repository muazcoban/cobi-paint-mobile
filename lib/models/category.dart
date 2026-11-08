class Category {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final int order;
  final bool isImportCategory;

  Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    this.order = 0,
    this.isImportCategory = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'] ?? json['name'],
      icon: json['icon'] ?? '',
      order: json['order'] ?? 0,
      isImportCategory: json['isImportCategory'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'icon': icon,
      'order': order,
      'isImportCategory': isImportCategory,
    };
  }

  /// New categories go after the existing ones: a child finds the cards by
  /// where they are, so the older cards keep their places.
  static List<Category> getDefaultCategories() {
    return [
      Category(id: 'animals', name: 'Hayvanlar', nameEn: 'Animals', icon: '🐾', order: 1),
      Category(id: 'plants', name: 'Bitkiler', nameEn: 'Plants', icon: '🌸', order: 2),
      Category(id: 'vehicles', name: 'Araçlar', nameEn: 'Vehicles', icon: '🚗', order: 3),
      Category(id: 'nature', name: 'Doğa', nameEn: 'Nature', icon: '🌈', order: 5),
      Category(id: 'food', name: 'Yiyecekler', nameEn: 'Food', icon: '🍎', order: 6),
      Category(id: 'things', name: 'Eşyalar', nameEn: 'Things', icon: '🧸', order: 7),
      Category(id: 'space', name: 'Uzay', nameEn: 'Space', icon: '🪐', order: 8),
      Category(id: 'music', name: 'Müzik', nameEn: 'Music', icon: '🎸', order: 9),
      Category(id: 'clothes', name: 'Giysiler', nameEn: 'Clothes', icon: '👕', order: 10),
      Category(id: 'celebrations', name: 'Kutlamalar', nameEn: 'Celebrations', icon: '🎉', order: 11),
      Category(id: 'import', name: 'İçe Aktar', nameEn: 'Import', icon: '📥', order: 99, isImportCategory: true),
    ];
  }
}
