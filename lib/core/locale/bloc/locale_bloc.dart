import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/utils/shared_preferences_helper.dart';
import 'locale_event.dart';
import 'locale_state.dart';

@injectable
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferencesHelper _sharedPreferencesHelper;

  LocaleBloc(this._sharedPreferencesHelper) : super(const LocaleState()) {
    on<LoadLocaleEvent>(_onLoadLocale);
    on<ChangeLocaleEvent>(_onChangeLocale);
  }

  Future<void> _onLoadLocale(
    LoadLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final localeCode = _sharedPreferencesHelper.getString('locale') ?? 'en';
    emit(state.copyWith(locale: Locale(localeCode)));
  }

  Future<void> _onChangeLocale(
    ChangeLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    await _sharedPreferencesHelper.setString('locale', event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }
}
