import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/user_settings.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../services/haptics.dart';
import '../services/purchase_service.dart';
import '../services/sound_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import 'full_version_screen.dart';

/// Everything for grown-ups, reached only through the parental gate:
/// mode, language, theme, sound, keeping the child in the app, privacy.
class ParentsScreen extends StatelessWidget {
  const ParentsScreen({super.key});

  static const contactEmail = 'cobipaint@gmail.com';

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
          if (PurchaseService.enabled) ...[
            _Section(l10n.fullVersion),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(l10n.fullVersion),
              subtitle: Text(l10n.fullVersionShort),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FullVersionScreen())),
            ),
          ],
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
          _Section(l10n.pageLevel),
          Text(l10n.pageLevelDesc),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in {0: l10n.levelAuto, 1: l10n.level1, 2: l10n.level2, 3: l10n.level3}.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: settings.level == entry.key,
                  onSelected: (_) => app.updateSettings(settings.copyWith(level: entry.key)),
                ),
            ],
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
                  label: Text(_themeName(l10n, entry.key)),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.haptics),
            value: settings.hapticsEnabled,
            onChanged: (enabled) {
              Haptics.enabled = enabled;
              app.updateSettings(settings.copyWith(hapticsEnabled: enabled));
              Haptics.selection();
            },
          ),
          // Shown only once clips for this language are bundled (K-04): a
          // switch that changes nothing would mislead a parent.
          FutureBuilder<bool>(
            future: VoiceService().hasVoice(localeProvider.locale.languageCode),
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox.shrink();
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.voiceNames),
                value: settings.voiceEnabled,
                onChanged: (enabled) {
                  VoiceService().enabled = enabled;
                  app.updateSettings(settings.copyWith(voiceEnabled: enabled));
                },
              );
            },
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
            leading: const Icon(Icons.article_outlined),
            title: Text(l10n.licenses),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLicensePage(context: context, applicationName: 'Cobi Paint'),
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

String _themeName(AppLocalizations l10n, String key) => switch (key) {
      'ocean' => l10n.themeOcean,
      'forest' => l10n.themeForest,
      'sunset' => l10n.themeSunset,
      _ => l10n.themeCoral,
    };

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
        // The purchase paragraph belongs to builds that sell the Full Version
        // (COBI_IAP); a reviewer of a build without it would look for a
        // purchase that is not there (K-15).
        child: SelectableText(
          PurchaseService.enabled ? '${l10n.privacyPolicyText}\n\n${l10n.privacyPolicyPurchase}' : l10n.privacyPolicyText,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
