import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'providers/locale_provider.dart';
import 'services/purchase_service.dart';
import 'services/sound_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The coloring pages are drawn from Fluent UI Emoji (MIT); its notice
  // shows with the other licences in the Parents area.
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/licenses/fluentui-emoji.txt');
    yield LicenseEntryWithLineBreaks(const ['Fluent UI Emoji (coloring pages)'], text);
  });

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Dark status bar content on the light screens (iOS and Android).
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  if (PurchaseService.enabled) unawaited(PurchaseService().init());
  runApp(const CobiPaintApp());

  // After the first frame, so neither delays the app appearing:
  // Android hides the system bars, so a stray swipe only reveals them
  // instead of leaving the app; sounds load ahead of the first tap.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
    }
    unawaited(Future<void>.delayed(const Duration(seconds: 1), SoundService().preload));
  });
}

class CobiPaintApp extends StatelessWidget {
  const CobiPaintApp({super.key, this.app});

  /// A ready provider; tests pass one that writes to a temporary folder.
  final AppProvider? app;

  @override
  Widget build(BuildContext context) {
    final app = this.app;
    return MultiProvider(
      providers: [
        if (app == null)
          ChangeNotifierProvider(create: (_) => AppProvider())
        else
          ChangeNotifierProvider<AppProvider>.value(value: app),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
      ],
      child: Consumer2<AppProvider, LocaleProvider>(
        builder: (context, appProvider, localeProvider, _) {
          // Theme and locale changes rebuild the app in place; no key, so the
          // navigation stack (and the parents area) survives them.
          return MaterialApp(
            title: 'Cobi Paint',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleProvider.supportedLocales,
            // Text may grow to 200% (HIG) but no further, so big type cannot
            // break the fixed-size kid layouts.
            builder: (context, child) => MediaQuery.withClampedTextScaling(maxScaleFactor: 2.0, child: child!),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
