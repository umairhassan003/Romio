import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/router/web_router.dart';
import 'core/theme/web_theme.dart';

class RomioAdminApp extends StatelessWidget {
  const RomioAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RomioAdminAppState(),
      child: Consumer<RomioAdminAppState>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            title: 'Romio Admin',
            debugShowCheckedModeBanner: false,
            theme: WebTheme.lightTheme,
            darkTheme: WebTheme.darkTheme,
            themeMode: appState.themeMode,
            locale: appState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: webRouter,
          );
        },
      ),
    );
  }
}

class RomioAdminAppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
