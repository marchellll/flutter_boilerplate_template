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

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      versionId: map['version_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'version_id': versionId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

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
