import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String versionId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.versionId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookId,
        chapterNumber,
        verseNumber,
        versionId,
        title,
        content,
        createdAt,
        updatedAt,
      ];
}
