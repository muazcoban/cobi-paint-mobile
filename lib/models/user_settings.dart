/// Little: huge buttons, 9 colours, no zoom (the default, for a 3-year-old).
/// Big: 16 colours, pinch zoom, brush sizes, redo.
enum AgeMode { little, big }

class UserSettings {
  final String selectedTheme; // 'coral', 'ocean', 'forest', 'sunset'
  final bool soundEnabled;
  final bool hapticsEnabled;

  /// Page level a parent pinned (1-3); 0 lets the app choose.
  final int level;

  /// Fills the child has made in the app so far, counted up to 3: the idle
  /// hint on the coloring screen stops once they know how to tap.
  final int firstFills;
  final double soundVolume;
  final AgeMode ageMode;

  UserSettings({
    this.selectedTheme = 'coral',
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.level = 0,
    this.firstFills = 0,
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
      hapticsEnabled: json['hapticsEnabled'] ?? true,
      level: (json['level'] as num?)?.toInt() ?? 0,
      firstFills: (json['firstFills'] as num?)?.toInt() ?? 0,
      soundVolume: ((json['soundVolume'] as num?) ?? 0.7).toDouble(),
      ageMode: json['ageMode'] == AgeMode.big.name ? AgeMode.big : AgeMode.little,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTheme': selectedTheme,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'level': level,
      'firstFills': firstFills,
      'soundVolume': soundVolume,
      'ageMode': ageMode.name,
    };
  }

  UserSettings copyWith({
    String? selectedTheme,
    bool? soundEnabled,
    bool? hapticsEnabled,
    int? level,
    int? firstFills,
    double? soundVolume,
    AgeMode? ageMode,
  }) {
    return UserSettings(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      level: level ?? this.level,
      firstFills: firstFills ?? this.firstFills,
      soundVolume: soundVolume ?? this.soundVolume,
      ageMode: ageMode ?? this.ageMode,
    );
  }
}
