// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:another_bible/core/locale/bloc/locale_bloc.dart' as _i258;
import 'package:another_bible/core/network/dio_client.dart' as _i273;
import 'package:another_bible/core/theme/bloc/theme_bloc.dart' as _i387;
import 'package:another_bible/core/utils/shared_preferences_helper.dart'
    as _i866;
import 'package:another_bible/features/bible/data/datasources/database_service.dart'
    as _i834;
import 'package:another_bible/features/bible/data/repositories/bible_repository_impl.dart'
    as _i514;
import 'package:another_bible/features/bible/domain/repositories/bible_repository.dart'
    as _i356;
import 'package:another_bible/features/bible/domain/usecases/get_bible_versions.dart'
    as _i400;
import 'package:another_bible/features/bible/domain/usecases/get_books.dart'
    as _i207;
import 'package:another_bible/features/bible/domain/usecases/get_verses.dart'
    as _i159;
import 'package:another_bible/features/bible/presentation/bloc/bible_reader_bloc.dart'
    as _i646;
import 'package:another_bible/features/bible/presentation/bloc/simple_bible_bloc.dart'
    as _i729;
import 'package:another_bible/features/todo/data/datasources/todo_local_datasource.dart'
    as _i722;
import 'package:another_bible/features/todo/data/repositories/todo_repository_impl.dart'
    as _i195;
import 'package:another_bible/features/todo/domain/repositories/todo_repository.dart'
    as _i849;
import 'package:another_bible/features/todo/domain/usecases/add_todo.dart'
    as _i370;
import 'package:another_bible/features/todo/domain/usecases/delete_todo.dart'
    as _i652;
import 'package:another_bible/features/todo/domain/usecases/get_todos.dart'
    as _i273;
import 'package:another_bible/features/todo/domain/usecases/update_todo.dart'
    as _i523;
import 'package:another_bible/features/todo/presentation/bloc/todo_bloc.dart'
    as _i333;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i729.SimpleBibleBloc>(() => _i729.SimpleBibleBloc());
    gh.singleton<_i273.DioClient>(() => _i273.DioClient());
    gh.singleton<_i866.SharedPreferencesHelper>(
      () => _i866.SharedPreferencesHelper(),
    );
    gh.singleton<_i834.DatabaseService>(() => _i834.DatabaseService());
    gh.factory<_i356.BibleRepository>(
      () => _i514.BibleRepositoryImpl(gh<_i834.DatabaseService>()),
    );
    gh.factory<_i387.ThemeBloc>(
      () => _i387.ThemeBloc(gh<_i866.SharedPreferencesHelper>()),
    );
    gh.factory<_i159.GetVerses>(
      () => _i159.GetVerses(gh<_i356.BibleRepository>()),
    );
    gh.factory<_i400.GetBibleVersions>(
      () => _i400.GetBibleVersions(gh<_i356.BibleRepository>()),
    );
    gh.factory<_i207.GetBooks>(
      () => _i207.GetBooks(gh<_i356.BibleRepository>()),
    );
    gh.factory<_i646.BibleReaderBloc>(
      () => _i646.BibleReaderBloc(
        gh<_i207.GetBooks>(),
        gh<_i159.GetVerses>(),
        gh<_i400.GetBibleVersions>(),
        gh<_i356.BibleRepository>(),
      ),
    );
    gh.factory<_i722.TodoLocalDataSource>(
      () => _i722.TodoLocalDataSourceImpl(),
    );
    gh.factory<_i258.LocaleBloc>(
      () => _i258.LocaleBloc(gh<_i866.SharedPreferencesHelper>()),
    );
    gh.factory<_i849.TodoRepository>(
      () => _i195.TodoRepositoryImpl(gh<_i722.TodoLocalDataSource>()),
    );
    gh.factory<_i370.AddTodo>(() => _i370.AddTodo(gh<_i849.TodoRepository>()));
    gh.factory<_i523.UpdateTodo>(
      () => _i523.UpdateTodo(gh<_i849.TodoRepository>()),
    );
    gh.factory<_i273.GetTodos>(
      () => _i273.GetTodos(gh<_i849.TodoRepository>()),
    );
    gh.factory<_i652.DeleteTodo>(
      () => _i652.DeleteTodo(gh<_i849.TodoRepository>()),
    );
    gh.factory<_i333.TodoBloc>(
      () => _i333.TodoBloc(
        gh<_i273.GetTodos>(),
        gh<_i370.AddTodo>(),
        gh<_i523.UpdateTodo>(),
        gh<_i652.DeleteTodo>(),
      ),
    );
    return this;
  }
}
