import 'package:equatable/equatable.dart';

class BookName extends Equatable {
  final int id;
  final String bookCode; // Foreign key to books.code
  final String language; // Language code like 'en', 'id', etc.
  final String abbreviation; // Short abbreviation like "Kej.", "Neh."
  final String shortName; // Short name like "Kejadian", "Nehemiah"
  final String longName; // Long name like "Kitab Kejadian", "Kitab Nehemiah"
  final String? altName; // Alternative name if any

  const BookName({
    required this.id,
    required this.bookCode,
    required this.language,
    required this.abbreviation,
    required this.shortName,
    required this.longName,
    this.altName,
  });

  factory BookName.fromMap(Map<String, dynamic> map) {
    return BookName(
      id: map['id'] as int,
      bookCode: map['book_code'] as String,
      language: map['language'] as String,
      abbreviation: map['abbreviation'] as String,
      shortName: map['short_name'] as String,
      longName: map['long_name'] as String,
      altName: map['alt_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_code': bookCode,
      'language': language,
      'abbreviation': abbreviation,
      'short_name': shortName,
      'long_name': longName,
      'alt_name': altName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        bookCode,
        language,
        abbreviation,
        shortName,
        longName,
        altName,
      ];
}
