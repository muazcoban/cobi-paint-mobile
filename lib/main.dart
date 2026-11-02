import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'providers/locale_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CobiPaintApp());
}

class CobiPaintApp extends StatelessWidget {
  const CobiPaintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
      ],
      child: Consumer2<AppProvider, LocaleProvider>(
        builder: (context, appProvider, localeProvider, _) {
          // Rebuild MaterialApp when theme or locale changes
          return MaterialApp(
            key: ValueKey('${appProvider.settings.selectedTheme}_${localeProvider.locale.languageCode}'),
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
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
