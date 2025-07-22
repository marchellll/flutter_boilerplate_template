import 'package:equatable/equatable.dart';
import '../../domain/entities/highlight.dart';
import '../../domain/entities/note.dart';

abstract class BibleReaderEvent extends Equatable {
  const BibleReaderEvent();

  @override
  List<Object?> get props => [];
}

class LoadChapter extends BibleReaderEvent {
  final int bookId;
  final int chapterNumber;
  final String versionId;

  const LoadChapter({
    required this.bookId,
    required this.chapterNumber,
    required this.versionId,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, versionId];
}

class NavigateToNextChapter extends BibleReaderEvent {
  const NavigateToNextChapter();
}

class NavigateToPreviousChapter extends BibleReaderEvent {
  const NavigateToPreviousChapter();
}

class NavigateToReference extends BibleReaderEvent {
  final int bookId;
  final int chapterNumber;
  final int? verseNumber;

  const NavigateToReference({
    required this.bookId,
    required this.chapterNumber,
    this.verseNumber,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, verseNumber];
}

class ChangeVersion extends BibleReaderEvent {
  final String versionId;

  const ChangeVersion(this.versionId);

  @override
  List<Object?> get props => [versionId];
}

class AddHighlight extends BibleReaderEvent {
  final Highlight highlight;

  const AddHighlight(this.highlight);

  @override
  List<Object?> get props => [highlight];
}

class AddNote extends BibleReaderEvent {
  final Note note;

  const AddNote(this.note);

  @override
  List<Object?> get props => [note];
}

class LoadInitialData extends BibleReaderEvent {
  const LoadInitialData();
}
