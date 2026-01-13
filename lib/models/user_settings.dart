class UserSettings {
  final bool isPro;
  final int dailyImportCount;
  final DateTime lastImportDate;
  final String selectedTheme; // 'coral', 'ocean', 'forest', 'sunset'
  final String language;
  final bool soundEnabled;
  final double soundVolume;

  static const int maxFreeImportsPerDay = 3;

  UserSettings({
    this.isPro = false,
    this.dailyImportCount = 0,
    DateTime? lastImportDate,
    this.selectedTheme = 'coral',
    this.language = 'tr',
    this.soundEnabled = true,
    this.soundVolume = 0.7,
  }) : lastImportDate = lastImportDate ?? DateTime.now();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isPro: json['isPro'] ?? false,
      dailyImportCount: json['dailyImportCount'] ?? 0,
      lastImportDate: json['lastImportDate'] != null
          ? DateTime.parse(json['lastImportDate'])
          : DateTime.now(),
      selectedTheme: json['selectedTheme'] ?? 'coral',
      language: json['language'] ?? 'tr',
      soundEnabled: json['soundEnabled'] ?? true,
      soundVolume: (json['soundVolume'] ?? 0.7).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPro': isPro,
      'dailyImportCount': dailyImportCount,
      'lastImportDate': lastImportDate.toIso8601String(),
      'selectedTheme': selectedTheme,
      'language': language,
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
    };
  }

  UserSettings copyWith({
    bool? isPro,
    int? dailyImportCount,
    DateTime? lastImportDate,
    String? selectedTheme,
    String? language,
    bool? soundEnabled,
    double? soundVolume,
  }) {
    return UserSettings(
      isPro: isPro ?? this.isPro,
      dailyImportCount: dailyImportCount ?? this.dailyImportCount,
      lastImportDate: lastImportDate ?? this.lastImportDate,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }

  bool canImportToday() {
    // Temporarily allow unlimited imports for initial launch
    // TODO: Uncomment when ready to enable in-app purchases
    return true;

    // Original logic:
    // if (isPro) return true;
    //
    // final now = DateTime.now();
    // final today = DateTime(now.year, now.month, now.day);
    // final lastDate = DateTime(
    //   lastImportDate.year,
    //   lastImportDate.month,
    //   lastImportDate.day,
    // );
    //
    // if (today.isAfter(lastDate)) {
    //   return true; // New day, reset count
    // }
    //
    // return dailyImportCount < maxFreeImportsPerDay;
  }

  int getRemainingImports() {
    if (isPro) return -1; // Unlimited

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastImportDate.year,
      lastImportDate.month,
      lastImportDate.day,
    );

    if (today.isAfter(lastDate)) {
      return maxFreeImportsPerDay;
    }

    return maxFreeImportsPerDay - dailyImportCount;
  }
}
