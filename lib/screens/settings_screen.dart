import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language Selection
              _SectionTitle(title: l10n.language),
              _LanguageSelector(
                currentLocale: localeProvider.locale,
                onLanguageSelected: (locale) {
                  localeProvider.setLocale(locale);
                },
              ),

              const SizedBox(height: 20),

              // Theme Selection
              _SectionTitle(title: 'Tema'),
              _ThemeSelector(
                selectedTheme: provider.settings.selectedTheme,
                onThemeSelected: (theme) {
                  provider.updateSettings(
                    provider.settings.copyWith(selectedTheme: theme),
                  );
                  AppTheme.setTheme(theme);
                  // Force rebuild
                  (context as Element).markNeedsBuild();
                },
              ),

              const SizedBox(height: 20),

              // Sound Settings
              _SectionTitle(title: l10n.soundEffects),
              _SoundSettingsTile(
                soundEnabled: provider.settings.soundEnabled,
                soundVolume: provider.settings.soundVolume,
                onSoundToggle: (enabled) {
                  provider.updateSettings(
                    provider.settings.copyWith(soundEnabled: enabled),
                  );
                  SoundService().setSoundEnabled(enabled);
                  if (enabled) {
                    // Play a test sound when enabling
                    SoundService().playClickSound();
                  }
                },
                onVolumeChanged: (volume) {
                  provider.updateSettings(
                    provider.settings.copyWith(soundVolume: volume),
                  );
                  SoundService().setVolume(volume);
                },
              ),

              const SizedBox(height: 20),

              // App Info
              _SectionTitle(title: l10n.about),
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: '${l10n.version} 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎨', style: TextStyle(fontSize: 30)),
            SizedBox(width: 10),
            Text('Cobi Paint'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiyon: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Çocuklar için eğlenceli ve yaratıcı boyama uygulaması.',
            ),
            SizedBox(height: 16),
            Text(
              '3-6 yaş grubu çocuklar için tasarlandı.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String selectedTheme;
  final ValueChanged<String> onThemeSelected;

  const _ThemeSelector({
    required this.selectedTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: AppTheme.themes.entries.map((entry) {
          final isSelected = entry.key == selectedTheme;
          final theme = entry.value;
          return GestureDetector(
            onTap: () => onThemeSelected(entry.key),
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? theme.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: theme.primary, width: 2)
                    : null,
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primary, theme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(theme.icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    theme.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLanguageSelected;

  const _LanguageSelector({
    required this.currentLocale,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'tr', 'name': 'Turkce', 'flag': '\u{1F1F9}\u{1F1F7}'},
      {'code': 'en', 'name': 'English', 'flag': '\u{1F1FA}\u{1F1F8}'},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: languages.map((lang) {
          final isSelected = currentLocale.languageCode == lang['code'];
          return GestureDetector(
            onTap: () => onLanguageSelected(Locale(lang['code']!)),
            child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppTheme.primaryColor, width: 2)
                    : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SoundSettingsTile extends StatelessWidget {
  final bool soundEnabled;
  final double soundVolume;
  final ValueChanged<bool> onSoundToggle;
  final ValueChanged<double> onVolumeChanged;

  const _SoundSettingsTile({
    required this.soundEnabled,
    required this.soundVolume,
    required this.onSoundToggle,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Ses Efektleri',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Switch(
                value: soundEnabled,
                onChanged: onSoundToggle,
                activeThumbColor: AppTheme.primaryColor,
              ),
            ],
          ),
          if (soundEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.volume_down, size: 20, color: AppTheme.textSecondary),
                Expanded(
                  child: Slider(
                    value: soundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppTheme.primaryColor,
                    onChanged: onVolumeChanged,
                  ),
                ),
                const Icon(Icons.volume_up, size: 20, color: AppTheme.textSecondary),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
