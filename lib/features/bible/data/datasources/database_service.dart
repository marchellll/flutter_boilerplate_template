import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';

@singleton
class DatabaseService {
  static const String _databaseName = 'bible_app.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/$_databaseName';

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create books table
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        name_local TEXT NOT NULL,
        abbreviation TEXT NOT NULL,
        chapter_count INTEGER NOT NULL,
        testament TEXT NOT NULL,
        book_order INTEGER NOT NULL
      )
    ''');

    // Create chapters table
    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY,
        book_id INTEGER NOT NULL,
        chapter_number INTEGER NOT NULL,
        verse_count INTEGER NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id)
      )
    ''');

    // Create bible_versions table
    await db.execute('''
      CREATE TABLE bible_versions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        full_name TEXT NOT NULL,
        language TEXT NOT NULL,
        description TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create verses table
    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY,
        book_id INTEGER NOT NULL,
        chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        version_id TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id),
        FOREIGN KEY (version_id) REFERENCES bible_versions (id)
      )
    ''');

    // Create highlights table
    await db.execute('''
      CREATE TABLE highlights (
        id INTEGER PRIMARY KEY,
        book_id INTEGER NOT NULL,
        chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        version_id TEXT NOT NULL,
        color TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (book_id) REFERENCES books (id),
        FOREIGN KEY (version_id) REFERENCES bible_versions (id)
      )
    ''');

    // Create notes table
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY,
        book_id INTEGER NOT NULL,
        chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        version_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (book_id) REFERENCES books (id),
        FOREIGN KEY (version_id) REFERENCES bible_versions (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_verses_book_chapter ON verses(book_id, chapter_number)');
    await db.execute('CREATE INDEX idx_verses_version ON verses(version_id)');
    await db.execute('CREATE INDEX idx_highlights_verse ON highlights(book_id, chapter_number, verse_number)');
    await db.execute('CREATE INDEX idx_notes_verse ON notes(book_id, chapter_number, verse_number)');

    // Create full-text search table for verses
    await db.execute('''
      CREATE VIRTUAL TABLE verses_fts USING fts5(
        verse_id,
        text,
        book_name,
        chapter_number,
        verse_number,
        version_id
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
