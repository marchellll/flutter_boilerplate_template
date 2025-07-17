import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class GetTodos {
  final TodoRepository repository;

  GetTodos(this.repository);

  Future<Either<Failure, List<Todo>>> call() async {
    return await repository.getTodos();
  }
}
