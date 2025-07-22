import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/bible_version.dart';
import '../../domain/entities/highlight.dart';
import '../../domain/entities/note.dart';

abstract class BibleReaderState extends Equatable {
  const BibleReaderState();

  @override
  List<Object?> get props => [];
}

class BibleReaderInitial extends BibleReaderState {
  const BibleReaderInitial();
}

class BibleReaderLoading extends BibleReaderState {
  const BibleReaderLoading();
}

class BibleReaderLoaded extends BibleReaderState {
  final Book currentBook;
  final int currentChapter;
  final List<Verse> verses;
  final BibleVersion currentVersion;
  final List<BibleVersion> availableVersions;
  final List<Book> books;
  final List<Highlight> highlights;
  final List<Note> notes;
  final bool isTopBarVisible;

  const BibleReaderLoaded({
    required this.currentBook,
    required this.currentChapter,
    required this.verses,
    required this.currentVersion,
    required this.availableVersions,
    required this.books,
    required this.highlights,
    required this.notes,
    this.isTopBarVisible = true,
  });

  @override
  List<Object?> get props => [
        currentBook,
        currentChapter,
        verses,
        currentVersion,
        availableVersions,
        books,
        highlights,
        notes,
        isTopBarVisible,
      ];

  BibleReaderLoaded copyWith({
    Book? currentBook,
    int? currentChapter,
    List<Verse>? verses,
    BibleVersion? currentVersion,
    List<BibleVersion>? availableVersions,
    List<Book>? books,
    List<Highlight>? highlights,
    List<Note>? notes,
    bool? isTopBarVisible,
  }) {
    return BibleReaderLoaded(
      currentBook: currentBook ?? this.currentBook,
      currentChapter: currentChapter ?? this.currentChapter,
      verses: verses ?? this.verses,
      currentVersion: currentVersion ?? this.currentVersion,
      availableVersions: availableVersions ?? this.availableVersions,
      books: books ?? this.books,
      highlights: highlights ?? this.highlights,
      notes: notes ?? this.notes,
      isTopBarVisible: isTopBarVisible ?? this.isTopBarVisible,
    );
  }
}

class BibleReaderError extends BibleReaderState {
  final String message;

  const BibleReaderError(this.message);

  @override
  List<Object?> get props => [message];
}
