import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_theme.dart';
import 'package:milliy_metr/core/router/app_router.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/core/storage/hive_storage.dart';
import 'package:milliy_metr/core/providers/theme_provider.dart';
import 'package:milliy_metr/core/providers/locale_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:milliy_metr/l10n/app_localizations.dart';
import 'package:milliy_metr/shared/components/responsive_wrapper.dart';



final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Falling back to defaults.');
  }
  await PreferencesManager.init();
  await HiveStorage.init();
  
  
  runApp(const ProviderScope(child: MilliyMetrApp()));
}

class MilliyMetrApp extends ConsumerWidget {
  const MilliyMetrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Milliy Metr',
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              overscroll: false,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
