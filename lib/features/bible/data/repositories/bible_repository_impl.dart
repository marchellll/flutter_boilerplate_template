import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/bible_version.dart';
import '../../domain/entities/highlight.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/database_service.dart';

@Injectable(as: BibleRepository)
class BibleRepositoryImpl implements BibleRepository {
  final DatabaseService _databaseService;

  BibleRepositoryImpl(this._databaseService);

  @override
  Future<Either<Failure, List<BibleVersion>>> getVersions() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query('bible_versions', orderBy: 'is_default DESC, name ASC');
      
      final versions = maps.map((map) => BibleVersion(
        id: map['id'] as String,
        name: map['name'] as String,
        fullName: map['full_name'] as String,
        language: map['language'] as String,
        description: map['description'] as String,
        isDefault: (map['is_default'] as int) == 1,
      )).toList();
      
      return Right(versions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BibleVersion?>> getDefaultVersion() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'bible_versions',
        where: 'is_default = ?',
        whereArgs: [1],
        limit: 1,
      );
      
      if (maps.isEmpty) return const Right(null);
      
      final map = maps.first;
      final version = BibleVersion(
        id: map['id'] as String,
        name: map['name'] as String,
        fullName: map['full_name'] as String,
        language: map['language'] as String,
        description: map['description'] as String,
        isDefault: (map['is_default'] as int) == 1,
      );
      
      return Right(version);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query('books', orderBy: 'book_order ASC');
      
      final books = maps.map((map) => Book(
        id: map['id'] as int,
        name: map['name'] as String,
        nameLocal: map['name_local'] as String,
        abbreviation: map['abbreviation'] as String,
        chapterCount: map['chapter_count'] as int,
        testament: map['testament'] as String,
        order: map['book_order'] as int,
      )).toList();
      
      return Right(books);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book?>> getBookById(int bookId) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'books',
        where: 'id = ?',
        whereArgs: [bookId],
        limit: 1,
      );
      
      if (maps.isEmpty) return const Right(null);
      
      final map = maps.first;
      final book = Book(
        id: map['id'] as int,
        name: map['name'] as String,
        nameLocal: map['name_local'] as String,
        abbreviation: map['abbreviation'] as String,
        chapterCount: map['chapter_count'] as int,
        testament: map['testament'] as String,
        order: map['book_order'] as int,
      );
      
      return Right(book);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book?>> getBookByName(String name) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'books',
        where: 'name LIKE ? OR name_local LIKE ? OR abbreviation LIKE ?',
        whereArgs: ['%$name%', '%$name%', '%$name%'],
        limit: 1,
      );
      
      if (maps.isEmpty) return const Right(null);
      
      final map = maps.first;
      final book = Book(
        id: map['id'] as int,
        name: map['name'] as String,
        nameLocal: map['name_local'] as String,
        abbreviation: map['abbreviation'] as String,
        chapterCount: map['chapter_count'] as int,
        testament: map['testament'] as String,
        order: map['book_order'] as int,
      );
      
      return Right(book);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Chapter>>> getChapters(int bookId) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'chapters',
        where: 'book_id = ?',
        whereArgs: [bookId],
        orderBy: 'chapter_number ASC',
      );
      
      final chapters = maps.map((map) => Chapter(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseCount: map['verse_count'] as int,
      )).toList();
      
      return Right(chapters);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Chapter?>> getChapter(int bookId, int chapterNumber) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'chapters',
        where: 'book_id = ? AND chapter_number = ?',
        whereArgs: [bookId, chapterNumber],
        limit: 1,
      );
      
      if (maps.isEmpty) return const Right(null);
      
      final map = maps.first;
      final chapter = Chapter(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseCount: map['verse_count'] as int,
      );
      
      return Right(chapter);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Verse>>> getVerses(int bookId, int chapterNumber, String versionId) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'verses',
        where: 'book_id = ? AND chapter_number = ? AND version_id = ?',
        whereArgs: [bookId, chapterNumber, versionId],
        orderBy: 'verse_number ASC',
      );
      
      final verses = maps.map((map) => Verse(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        text: map['text'] as String,
        versionId: map['version_id'] as String,
      )).toList();
      
      return Right(verses);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verse?>> getVerse(int bookId, int chapterNumber, int verseNumber, String versionId) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'verses',
        where: 'book_id = ? AND chapter_number = ? AND verse_number = ? AND version_id = ?',
        whereArgs: [bookId, chapterNumber, verseNumber, versionId],
        limit: 1,
      );
      
      if (maps.isEmpty) return const Right(null);
      
      final map = maps.first;
      final verse = Verse(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        text: map['text'] as String,
        versionId: map['version_id'] as String,
      );
      
      return Right(verse);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Verse>>> searchVerses(String query, String versionId) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.rawQuery('''
        SELECT v.* FROM verses v
        JOIN verses_fts fts ON v.id = fts.verse_id
        WHERE fts MATCH ? AND v.version_id = ?
        ORDER BY v.book_id, v.chapter_number, v.verse_number
      ''', [query, versionId]);
      
      final verses = maps.map((map) => Verse(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        text: map['text'] as String,
        versionId: map['version_id'] as String,
      )).toList();
      
      return Right(verses);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Highlight>>> getHighlights() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query('highlights', orderBy: 'created_at DESC');
      
      final highlights = maps.map((map) => Highlight(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        versionId: map['version_id'] as String,
        color: map['color'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      )).toList();
      
      return Right(highlights);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Highlight>>> getHighlightsForChapter(int bookId, int chapterNumber) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'highlights',
        where: 'book_id = ? AND chapter_number = ?',
        whereArgs: [bookId, chapterNumber],
        orderBy: 'verse_number ASC',
      );
      
      final highlights = maps.map((map) => Highlight(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        versionId: map['version_id'] as String,
        color: map['color'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      )).toList();
      
      return Right(highlights);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHighlight(Highlight highlight) async {
    try {
      final db = await _databaseService.database;
      await db.insert('highlights', {
        'book_id': highlight.bookId,
        'chapter_number': highlight.chapterNumber,
        'verse_number': highlight.verseNumber,
        'version_id': highlight.versionId,
        'color': highlight.color,
        'created_at': highlight.createdAt.toIso8601String(),
        'updated_at': highlight.updatedAt?.toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateHighlight(Highlight highlight) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'highlights',
        {
          'color': highlight.color,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [highlight.id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHighlight(int highlightId) async {
    try {
      final db = await _databaseService.database;
      await db.delete('highlights', where: 'id = ?', whereArgs: [highlightId]);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query('notes', orderBy: 'created_at DESC');
      
      final notes = maps.map((map) => Note(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        versionId: map['version_id'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      )).toList();
      
      return Right(notes);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getNotesForChapter(int bookId, int chapterNumber) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'notes',
        where: 'book_id = ? AND chapter_number = ?',
        whereArgs: [bookId, chapterNumber],
        orderBy: 'verse_number ASC',
      );
      
      final notes = maps.map((map) => Note(
        id: map['id'] as int,
        bookId: map['book_id'] as int,
        chapterNumber: map['chapter_number'] as int,
        verseNumber: map['verse_number'] as int,
        versionId: map['version_id'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      )).toList();
      
      return Right(notes);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addNote(Note note) async {
    try {
      final db = await _databaseService.database;
      await db.insert('notes', {
        'book_id': note.bookId,
        'chapter_number': note.chapterNumber,
        'verse_number': note.verseNumber,
        'version_id': note.versionId,
        'title': note.title,
        'content': note.content,
        'created_at': note.createdAt.toIso8601String(),
        'updated_at': note.updatedAt?.toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(Note note) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'notes',
        {
          'title': note.title,
          'content': note.content,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(int noteId) async {
    try {
      final db = await _databaseService.database;
      await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
