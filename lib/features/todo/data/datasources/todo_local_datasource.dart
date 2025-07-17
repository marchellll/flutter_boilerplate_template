import 'package:injectable/injectable.dart';
import '../../domain/entities/todo.dart';

abstract class TodoLocalDataSource {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(Todo todo);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}

@Injectable(as: TodoLocalDataSource)
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final List<Todo> _todos = [];

  @override
  Future<List<Todo>> getTodos() async {
    return List.from(_todos);
  }

  @override
  Future<Todo> addTodo(Todo todo) async {
    _todos.add(todo);
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    }
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
  }
}
