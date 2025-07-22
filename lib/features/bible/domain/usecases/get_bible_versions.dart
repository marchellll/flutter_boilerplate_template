import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/bible_version.dart';
import '../repositories/bible_repository.dart';

@injectable
class GetBibleVersions {
  final BibleRepository repository;

  GetBibleVersions(this.repository);

  Future<Either<Failure, List<BibleVersion>>> call() async {
    return await repository.getVersions();
  }
}
