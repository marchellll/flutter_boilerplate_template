import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/bible_repository.dart';

@injectable
class GetBooks {
  final BibleRepository repository;

  GetBooks(this.repository);

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getBooks();
  }
}
