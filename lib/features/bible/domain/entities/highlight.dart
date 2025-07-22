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
