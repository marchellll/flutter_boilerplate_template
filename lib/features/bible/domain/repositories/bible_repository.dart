import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../entities/chapter.dart';
import '../entities/verse.dart';
import '../entities/bible_version.dart';
import '../entities/highlight.dart';
import '../entities/note.dart';

abstract class BibleRepository {
  // Version operations
  Future<Either<Failure, List<BibleVersion>>> getVersions();
  Future<Either<Failure, BibleVersion?>> getDefaultVersion();
  
  // Book operations
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, Book?>> getBookById(int bookId);
  Future<Either<Failure, Book?>> getBookByName(String name);
  
  // Chapter operations
  Future<Either<Failure, List<Chapter>>> getChapters(int bookId);
  Future<Either<Failure, Chapter?>> getChapter(int bookId, int chapterNumber);
  
  // Verse operations
  Future<Either<Failure, List<Verse>>> getVerses(int bookId, int chapterNumber, String versionId);
  Future<Either<Failure, Verse?>> getVerse(int bookId, int chapterNumber, int verseNumber, String versionId);
  Future<Either<Failure, List<Verse>>> searchVerses(String query, String versionId);
  
  // Highlight operations
  Future<Either<Failure, List<Highlight>>> getHighlights();
  Future<Either<Failure, List<Highlight>>> getHighlightsForChapter(int bookId, int chapterNumber);
  Future<Either<Failure, void>> addHighlight(Highlight highlight);
  Future<Either<Failure, void>> updateHighlight(Highlight highlight);
  Future<Either<Failure, void>> deleteHighlight(int highlightId);
  
  // Note operations
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, List<Note>>> getNotesForChapter(int bookId, int chapterNumber);
  Future<Either<Failure, void>> addNote(Note note);
  Future<Either<Failure, void>> updateNote(Note note);
  Future<Either<Failure, void>> deleteNote(int noteId);
}
