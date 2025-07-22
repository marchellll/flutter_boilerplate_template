import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/verse.dart';
import '../repositories/bible_repository.dart';

@injectable
class GetVerses {
  final BibleRepository repository;

  GetVerses(this.repository);

  Future<Either<Failure, List<Verse>>> call({
    required int bookId,
    required int chapterNumber,
    required String versionId,
  }) async {
    return await repository.getVerses(bookId, chapterNumber, versionId);
  }
}
