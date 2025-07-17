// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_boilerplate_template/core/network/dio_client.dart'
    as _i3;
import 'package:flutter_boilerplate_template/core/theme/bloc/theme_bloc.dart'
    as _i5;
import 'package:flutter_boilerplate_template/core/utils/shared_preferences_helper.dart'
    as _i4;
import 'package:flutter_boilerplate_template/features/todo/data/datasources/todo_local_datasource.dart'
    as _i6;
import 'package:flutter_boilerplate_template/features/todo/data/repositories/todo_repository_impl.dart'
    as _i9;
import 'package:flutter_boilerplate_template/features/todo/domain/repositories/todo_repository.dart'
    as _i8;
import 'package:flutter_boilerplate_template/features/todo/domain/usecases/add_todo.dart'
    as _i11;
import 'package:flutter_boilerplate_template/features/todo/domain/usecases/delete_todo.dart'
    as _i12;
import 'package:flutter_boilerplate_template/features/todo/domain/usecases/get_todos.dart'
    as _i13;
import 'package:flutter_boilerplate_template/features/todo/domain/usecases/update_todo.dart'
    as _i10;
import 'package:flutter_boilerplate_template/features/todo/presentation/bloc/todo_bloc.dart'
    as _i14;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i3.DioClient>(() => _i3.DioClient());
    gh.singleton<_i4.SharedPreferencesHelper>(
        () => _i4.SharedPreferencesHelper());
    gh.factory<_i5.ThemeBloc>(
        () => _i5.ThemeBloc(gh<_i4.SharedPreferencesHelper>()));
    gh.factory<_i6.TodoLocalDataSource>(
        () => _i6.TodoLocalDataSourceImpl());
    gh.factory<_i8.TodoRepository>(
        () => _i9.TodoRepositoryImpl(gh<_i6.TodoLocalDataSource>()));
    gh.factory<_i10.UpdateTodo>(
        () => _i10.UpdateTodo(gh<_i8.TodoRepository>()));
    gh.factory<_i11.AddTodo>(() => _i11.AddTodo(gh<_i8.TodoRepository>()));
    gh.factory<_i12.DeleteTodo>(
        () => _i12.DeleteTodo(gh<_i8.TodoRepository>()));
    gh.factory<_i13.GetTodos>(() => _i13.GetTodos(gh<_i8.TodoRepository>()));
    gh.factory<_i14.TodoBloc>(() => _i14.TodoBloc(
          gh<_i13.GetTodos>(),
          gh<_i11.AddTodo>(),
          gh<_i10.UpdateTodo>(),
          gh<_i12.DeleteTodo>(),
        ));
    return this;
  }
}
