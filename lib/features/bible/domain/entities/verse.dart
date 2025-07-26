import 'package:equatable/equatable.dart';
import 'footnote.dart';

class Verse extends Equatable {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String versionId;
  final List<Footnote>? footnotes; // Associated footnotes for this verse

  const Verse({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.versionId,
    this.footnotes,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      text: map['text'] as String,
      versionId: map['version_id'] as String,
      footnotes: map['footnotes'] != null
          ? (map['footnotes'] as List<dynamic>)
              .map((f) => Footnote.fromMap(f as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'text': text,
      'version_id': versionId,
      'footnotes': footnotes?.map((f) => f.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        chapterNumber,
        verseNumber,
        text,
        versionId,
        footnotes,
      ];
}
