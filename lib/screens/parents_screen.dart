import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/user_settings.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

/// Everything for grown-ups, reached only through the parental gate:
/// mode, language, theme, sound, keeping the child in the app, privacy.
class ParentsScreen extends StatelessWidget {
  const ParentsScreen({super.key});

  static const contactEmail = 'muazcoban@icloud.com';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final app = context.watch<AppProvider>();
    final settings = app.settings;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentsArea)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.parentsHint, style: const TextStyle(color: AppTheme.textPrimary)),
          _Section(l10n.ageMode),
          RadioGroup<AgeMode>(
            groupValue: settings.ageMode,
            onChanged: (mode) {
              if (mode != null) app.setAgeMode(mode);
            },
            child: Column(
              children: [
                RadioListTile<AgeMode>(
                  value: AgeMode.little,
                  title: Text(l10n.ageModeLittle),
                  subtitle: Text(l10n.ageModeLittleDesc),
                ),
                RadioListTile<AgeMode>(
                  value: AgeMode.big,
                  title: Text(l10n.ageModeBig),
                  subtitle: Text(l10n.ageModeBigDesc),
                ),
              ],
            ),
          ),
          _Section(l10n.language),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in {'tr': l10n.turkish, 'en': l10n.english}.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: localeProvider.locale.languageCode == entry.key,
                  onSelected: (_) => localeProvider.setLocale(Locale(entry.key)),
                ),
            ],
          ),
          _Section(l10n.theme),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in AppTheme.themes.entries)
                ChoiceChip(
                  avatar: Text(entry.value.icon),
                  label: Text(entry.value.name),
                  selected: settings.selectedTheme == entry.key,
                  onSelected: (_) {
                    AppTheme.setTheme(entry.key);
                    app.updateSettings(settings.copyWith(selectedTheme: entry.key));
                  },
                ),
            ],
          ),
          _Section(l10n.soundEffects),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.soundEffects),
            value: settings.soundEnabled,
            onChanged: (enabled) {
              SoundService().setSoundEnabled(enabled);
              app.updateSettings(settings.copyWith(soundEnabled: enabled));
              if (enabled) SoundService().playClickSound();
            },
          ),
          Row(
            children: [
              const Icon(Icons.volume_down_rounded),
              Expanded(
                child: Slider(
                  value: settings.soundVolume,
                  label: l10n.soundVolume,
                  onChanged: settings.soundEnabled
                      ? (v) {
                          SoundService().setVolume(v);
                          app.updateSettings(settings.copyWith(soundVolume: v));
                        }
                      : null,
                ),
              ),
              const Icon(Icons.volume_up_rounded),
            ],
          ),
          _Section(l10n.guidedAccessTitle),
          Text(l10n.guidedAccessText),
          _Section(l10n.about),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(l10n.contactUs),
            subtitle: const SelectableText(contactEmail),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: contactEmail));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(contactEmail)));
            },
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
      ),
    );
  }
}

/// The privacy policy inside the app (App Review 5.1.1); no link out needed.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(l10n.privacyPolicyText, style: const TextStyle(fontSize: 16, height: 1.5)),
      ),
    );
  }
}
