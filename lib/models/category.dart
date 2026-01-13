class Category {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final int order;
  final bool isFromFirebase;
  final bool isImportCategory;

  Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    this.order = 0,
    this.isFromFirebase = false,
    this.isImportCategory = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'] ?? json['name'],
      icon: json['icon'] ?? '',
      order: json['order'] ?? 0,
      isFromFirebase: json['isFromFirebase'] ?? false,
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
      'isFromFirebase': isFromFirebase,
      'isImportCategory': isImportCategory,
    };
  }

  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'animals',
        name: 'Hayvanlar',
        nameEn: 'Animals',
        icon: '🐾',
        order: 1,
      ),
      Category(
        id: 'plants',
        name: 'Bitkiler',
        nameEn: 'Plants',
        icon: '🌸',
        order: 2,
      ),
      Category(
        id: 'vehicles',
        name: 'Araçlar',
        nameEn: 'Vehicles',
        icon: '🚗',
        order: 3,
      ),
      Category(
        id: 'characters',
        name: 'Karakterler',
        nameEn: 'Characters',
        icon: '👸',
        order: 4,
      ),
      Category(
        id: 'nature',
        name: 'Doğa',
        nameEn: 'Nature',
        icon: '🌈',
        order: 5,
      ),
      Category(
        id: 'food',
        name: 'Yiyecekler',
        nameEn: 'Food',
        icon: '🍎',
        order: 6,
      ),
      Category(
        id: 'import',
        name: 'İçe Aktar',
        nameEn: 'Import',
        icon: '📥',
        order: 99,
        isImportCategory: true,
      ),
    ];
  }
}
