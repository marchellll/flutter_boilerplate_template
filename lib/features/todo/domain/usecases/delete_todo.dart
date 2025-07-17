import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/todo_repository.dart';

@injectable
class DeleteTodo {
  final TodoRepository repository;

  DeleteTodo(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteTodo(id);
  }
}
