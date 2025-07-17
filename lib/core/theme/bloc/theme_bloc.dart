import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../constants/app_constants.dart';
import '../../utils/shared_preferences_helper.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferencesHelper preferencesHelper;

  ThemeBloc(this.preferencesHelper) : super(const ThemeState(ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  void _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final savedThemeIndex = preferencesHelper.getInt(AppConstants.themeKey);
    if (savedThemeIndex != null) {
      final themeMode = ThemeMode.values[savedThemeIndex];
      emit(ThemeState(themeMode));
    }
  }

  void _onChangeTheme(ChangeThemeEvent event, Emitter<ThemeState> emit) async {
    await preferencesHelper.setInt(AppConstants.themeKey, event.themeMode.index);
    emit(ThemeState(event.themeMode));
  }
}
