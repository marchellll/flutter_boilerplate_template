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

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapterNumber: map['chapter_number'] as int,
      verseCount: map['verse_count'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_count': verseCount,
    };
  }

  @override
  List<Object?> get props => [id, bookId, chapterNumber, verseCount];
}
