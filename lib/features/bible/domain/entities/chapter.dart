import 'package:equatable/equatable.dart';

class Chapter extends Equatable {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseCount;

  const Chapter({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseCount,
  });

  @override
  List<Object?> get props => [id, bookId, chapterNumber, verseCount];
}
