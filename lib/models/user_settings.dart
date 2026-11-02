/// Little: huge buttons, 8 colours, no zoom (the default, for a 3-year-old).
/// Big: 16 colours, pinch zoom, brush sizes, redo.
enum AgeMode { little, big }

class UserSettings {
  final String selectedTheme; // 'coral', 'ocean', 'forest', 'sunset'
  final bool soundEnabled;
  final double soundVolume;
  final AgeMode ageMode;

  UserSettings({
    this.selectedTheme = 'coral',
    this.soundEnabled = true,
    this.soundVolume = 0.7,
    this.ageMode = AgeMode.little,
  });

  // Settings saved by older versions may carry keys that no longer exist
  // (isPro, dailyImportCount, lastImportDate, language, coloringCompletedCount);
  // they are ignored here.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      selectedTheme: json['selectedTheme'] ?? 'coral',
      soundEnabled: json['soundEnabled'] ?? true,
      soundVolume: ((json['soundVolume'] as num?) ?? 0.7).toDouble(),
      ageMode: json['ageMode'] == AgeMode.big.name ? AgeMode.big : AgeMode.little,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTheme': selectedTheme,
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
      'ageMode': ageMode.name,
    };
  }

  UserSettings copyWith({
    String? selectedTheme,
    bool? soundEnabled,
    double? soundVolume,
    AgeMode? ageMode,
  }) {
    return UserSettings(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      ageMode: ageMode ?? this.ageMode,
    );
  }
}
