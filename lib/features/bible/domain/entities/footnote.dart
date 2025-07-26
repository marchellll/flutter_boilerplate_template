import 'package:equatable/equatable.dart';

class Footnote extends Equatable {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String versionId;
  final String footnoteType; // 'footnote', 'endnote', 'cross_reference', 'study_note'
  final String? caller; // The footnote marker like '+', '*', 'a', '1', etc.
  final String content;

  const Footnote({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.versionId,
    required this.footnoteType,
    this.caller,
    required this.content,
  });

  factory Footnote.fromMap(Map<String, dynamic> map) {
    return Footnote(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      versionId: map['version_id'] as String,
      footnoteType: map['footnote_type'] as String,
      caller: map['caller'] as String?,
      content: map['content'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'version_id': versionId,
      'footnote_type': footnoteType,
      'caller': caller,
      'content': content,
    };
  }

  bool get isFootnote => footnoteType == 'footnote';
  bool get isEndnote => footnoteType == 'endnote';
  bool get isCrossReference => footnoteType == 'cross_reference';
  bool get isStudyNote => footnoteType == 'study_note';

  @override
  List<Object?> get props => [
        id,
        bookId,
        chapterNumber,
        verseNumber,
        versionId,
        footnoteType,
        caller,
        content,
      ];
}
