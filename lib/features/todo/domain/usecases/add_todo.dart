import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class AddTodo {
  final TodoRepository repository;

  AddTodo(this.repository);

  Future<Either<Failure, Todo>> call(Todo todo) async {
    return await repository.addTodo(todo);
  }
}
