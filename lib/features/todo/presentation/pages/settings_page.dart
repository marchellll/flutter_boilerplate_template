import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/locale/bloc/locale_bloc.dart';
import '../../../../core/locale/bloc/locale_event.dart';
import '../../../../core/locale/bloc/locale_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.darkMode),
                  subtitle: const Text('Choose your preferred theme'),
                ),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: Text(l10n.lightMode),
                          value: ThemeMode.light,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(l10n.darkMode),
                          value: ThemeMode.dark,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('System'),
                          value: ThemeMode.system,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: const Text('Choose your preferred language'),
                ),
                BlocBuilder<LocaleBloc, LocaleState>(
                  builder: (context, localeState) {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('English'),
                          value: 'en',
                          groupValue: localeState.locale.languageCode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<LocaleBloc>().add(
                                ChangeLocaleEvent(Locale(value)),
                              );
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Bahasa Indonesia'),
                          value: 'id',
                          groupValue: localeState.locale.languageCode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<LocaleBloc>().add(
                                ChangeLocaleEvent(Locale(value)),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n.debugScreen),
              subtitle: const Text('View app debug information'),
              onTap: () {
                context.push('/debug');
              },
            ),
          ),
        ],
      ),
    );
  }
}
