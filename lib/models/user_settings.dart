class UserSettings {
  final String selectedTheme; // 'coral', 'ocean', 'forest', 'sunset'
  final bool soundEnabled;
  final double soundVolume;

  UserSettings({
    this.selectedTheme = 'coral',
    this.soundEnabled = true,
    this.soundVolume = 0.7,
  });

  // Settings saved by older versions may carry keys that no longer exist
  // (isPro, dailyImportCount, lastImportDate, language, coloringCompletedCount);
  // they are ignored here.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      selectedTheme: json['selectedTheme'] ?? 'coral',
      soundEnabled: json['soundEnabled'] ?? true,
      soundVolume: ((json['soundVolume'] as num?) ?? 0.7).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTheme': selectedTheme,
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
    };
  }

  UserSettings copyWith({
    String? selectedTheme,
    bool? soundEnabled,
    double? soundVolume,
  }) {
    return UserSettings(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }
}
