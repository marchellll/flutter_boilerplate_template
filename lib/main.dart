import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

import 'core/di/service_locator.dart';
import 'core/locale/bloc/locale_bloc.dart';
import 'core/locale/bloc/locale_event.dart';
import 'core/locale/bloc/locale_state.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/utils/app_router.dart';
import 'core/utils/shared_preferences_helper.dart';
import 'features/todo/presentation/bloc/todo_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependencies
  await configureDependencies();

  // Initialize SharedPreferences
  await getIt<SharedPreferencesHelper>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ThemeBloc>()..add(const LoadThemeEvent()),
        ),
        BlocProvider(
          create: (context) => getIt<LocaleBloc>()..add(const LoadLocaleEvent()),
        ),
        BlocProvider(
          create: (context) => getIt<TodoBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                title: 'Todo App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: localeState.locale,
                routerConfig: AppRouter.router,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('id'), // Indonesian
                ],
              );
            },
          );
        },
      ),
    );
  }
}
