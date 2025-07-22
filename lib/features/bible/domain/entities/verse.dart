import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String versionId;

  const Verse({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.versionId,
  });

  @override
  List<Object?> get props => [
        id,
        bookId,
        chapterNumber,
        verseNumber,
        text,
        versionId,
      ];
}
