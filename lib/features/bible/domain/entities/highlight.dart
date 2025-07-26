import 'package:equatable/equatable.dart';

class Highlight extends Equatable {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String versionId;
  final String color; // Hex color code
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Highlight({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.versionId,
    required this.color,
    required this.createdAt,
    this.updatedAt,
  });

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      versionId: map['version_id'] as String,
      color: map['color'] as String,
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
      'color': color,
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
        color,
        createdAt,
        updatedAt,
      ];
}
