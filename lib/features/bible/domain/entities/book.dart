import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final int id;
  final String name;
  final String nameLocal; // For localized names like "Kejadian" for Genesis
  final String abbreviation;
  final int chapterCount;
  final String testament; // 'OT' or 'NT'
  final int order; // Book order in Bible

  const Book({
    required this.id,
    required this.name,
    required this.nameLocal,
    required this.abbreviation,
    required this.chapterCount,
    required this.testament,
    required this.order,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        nameLocal,
        abbreviation,
        chapterCount,
        testament,
        order,
      ];
}
