import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../locale/bloc/locale_bloc.dart';
import '../utils/shared_preferences_helper.dart';
import 'service_locator.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  // Manually register LocaleBloc since build runner is having issues
  getIt.registerFactory<LocaleBloc>(
    () => LocaleBloc(getIt<SharedPreferencesHelper>()),
  );
}
