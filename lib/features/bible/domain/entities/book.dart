import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final int id;
  final String code; // Unique book code like "GEN", "NEH", etc.
  final String versionId; // Reference to bible version
  final String name; // English name like "Genesis", "Nehemiah"
  final String abbreviation; // Short abbreviation like "Kej.", "Neh."
  final String shortName; // Short name like "Kejadian", "Nehemiah"
  final String longName; // Long name like "Kitab Kejadian", "Kitab Nehemiah"
  final String? altName; // Alternative name if any
  final int chapterCount;
  final String testament; // 'OT' or 'NT'
  final int order; // Book order in Bible

  const Book({
    required this.id,
    required this.code,
    required this.versionId,
    required this.name,
    required this.abbreviation,
    required this.shortName,
    required this.longName,
    this.altName,
    required this.chapterCount,
    required this.testament,
    required this.order,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      code: map['code'] as String,
      versionId: map['version_id'] as String,
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      shortName: map['short_name'] as String,
      longName: map['long_name'] as String,
      altName: map['alt_name'] as String?,
      chapterCount: map['chapter_count'] as int,
      testament: map['testament'] as String,
      order: map['book_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'version_id': versionId,
      'name': name,
      'abbreviation': abbreviation,
      'short_name': shortName,
      'long_name': longName,
      'alt_name': altName,
      'chapter_count': chapterCount,
      'testament': testament,
      'book_order': order,
    };
  }

  bool get isOldTestament => testament == 'OT';
  bool get isNewTestament => testament == 'NT';

  @override
  List<Object?> get props => [
        id,
        code,
        versionId,
        name,
        abbreviation,
        shortName,
        longName,
        altName,
        chapterCount,
        testament,
        order,
      ];
}
