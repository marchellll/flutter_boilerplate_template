import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/update_todo.dart';

part 'todo_event.dart';
part 'todo_state.dart';

@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;

  TodoBloc(
    this.getTodos,
    this.addTodo,
    this.updateTodo,
    this.deleteTodo,
  ) : super(TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
  }

  void _onLoadTodos(LoadTodosEvent event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    final result = await getTodos();
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (todos) => emit(TodoLoaded(todos)),
    );
  }

  void _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(TodoLoading());

      final result = await addTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (newTodo) {
          final updatedTodos = List<Todo>.from(currentState.todos)..add(newTodo);
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }

  void _onUpdateTodo(UpdateTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(TodoLoading());

      final result = await updateTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (updatedTodo) {
          final updatedTodos = currentState.todos.map((todo) {
            return todo.id == updatedTodo.id ? updatedTodo : todo;
          }).toList();
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }

  void _onDeleteTodo(DeleteTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(TodoLoading());

      final result = await deleteTodo(event.id);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (_) {
          final updatedTodos = currentState.todos.where((todo) => todo.id != event.id).toList();
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }

  void _onToggleTodo(ToggleTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final todoToUpdate = currentState.todos.firstWhere((todo) => todo.id == event.id);
      final updatedTodo = todoToUpdate.copyWith(
        isCompleted: !todoToUpdate.isCompleted,
        updatedAt: DateTime.now(),
      );

      emit(TodoLoading());

      final result = await updateTodo(updatedTodo);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (updatedTodo) {
          final updatedTodos = currentState.todos.map((todo) {
            return todo.id == updatedTodo.id ? updatedTodo : todo;
          }).toList();
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }
}
