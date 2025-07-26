const Database = require('better-sqlite3');
const crypto = require('crypto');
const fs = require('fs');

/**
 * Builds optimized SQLite database with FTS5 search
 */
async function buildDatabase(parsedData, outputPath, sources = {}) {
  // Delete existing database if it exists
  if (fs.existsSync(outputPath)) {
    fs.unlinkSync(outputPath);
  }

  const db = new Database(outputPath);

  console.log('    🏗️ Creating database schema...');
  createSchema(db);

  console.log('    📋 Inserting Bible versions...');
  insertBibleVersions(db, sources);

  console.log('    📚 Inserting books...');
  const bookCodeToId = insertBooks(db, parsedData.books, parsedData.bookNames || []);

  console.log('    📖 Inserting chapters...');
  insertChapters(db, parsedData.chapters, bookCodeToId);

  console.log('    📝 Inserting verses...');
  insertVerses(db, parsedData.verses, bookCodeToId);

  console.log('    � Inserting footnotes...');
  insertFootnotes(db, parsedData.footnotes || [], bookCodeToId);

  console.log('    �🔍 Building search index...');
  buildSearchIndex(db);

  console.log('    🔧 Optimizing database...');
  optimizeDatabase(db);

  console.log('    💾 Creating metadata...');
  insertMetadata(db, parsedData);

  db.close();
  console.log(`    ✅ Database created: ${outputPath}`);
}

/**
 * Creates database schema matching Flutter entities exactly
 */
function createSchema(db) {
  // Bible versions table - matches BibleVersion entity
  db.exec(`
    CREATE TABLE bible_versions (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      full_name TEXT NOT NULL,
      language TEXT NOT NULL,
      description TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0
    );
  `);

  // Books table - matches Book entity (now includes localized names)
  db.exec(`
    CREATE TABLE books (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL,
      version_id TEXT NOT NULL,
      name TEXT NOT NULL,
      abbreviation TEXT NOT NULL,
      short_name TEXT NOT NULL,
      long_name TEXT NOT NULL,
      alt_name TEXT,
      chapter_count INTEGER NOT NULL DEFAULT 0,
      testament TEXT NOT NULL CHECK (testament IN ('OT', 'NT')),
      book_order INTEGER NOT NULL,
      FOREIGN KEY (version_id) REFERENCES bible_versions(id),
      UNIQUE(code, version_id)
    );
  `);

  // Remove book_names table since it's now merged with books

  // Chapters table - matches Chapter entity
  db.exec(`
    CREATE TABLE chapters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL,
      verse_count INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (book_id) REFERENCES books(id),
      UNIQUE(book_id, chapter_number)
    );
  `);

  // Verses table - matches Verse entity
  db.exec(`
    CREATE TABLE verses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL,
      verse_number INTEGER NOT NULL,
      text TEXT NOT NULL,
      version_id TEXT NOT NULL,
      FOREIGN KEY (book_id) REFERENCES books(id),
      FOREIGN KEY (version_id) REFERENCES bible_versions(id),
      UNIQUE(book_id, chapter_number, verse_number, version_id)
    );
  `);

  // Highlights table - matches Highlight entity
  db.exec(`
    CREATE TABLE highlights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL,
      verse_number INTEGER NOT NULL,
      version_id TEXT NOT NULL,
      color TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT NULL,
      FOREIGN KEY (book_id) REFERENCES books(id),
      FOREIGN KEY (version_id) REFERENCES bible_versions(id)
    );
  `);

  // Notes table - matches Note entity
  db.exec(`
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL,
      verse_number INTEGER NOT NULL,
      version_id TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT NULL,
      FOREIGN KEY (book_id) REFERENCES books(id),
      FOREIGN KEY (version_id) REFERENCES bible_versions(id)
    );
  `);

  // Footnotes table - for Bible footnotes and commentary
  db.exec(`
    CREATE TABLE footnotes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL,
      verse_number INTEGER NOT NULL,
      version_id TEXT NOT NULL,
      footnote_type TEXT NOT NULL CHECK (footnote_type IN ('footnote', 'endnote', 'cross_reference', 'study_note')),
      caller TEXT, -- The footnote marker like '+', '*', 'a', '1', etc.
      content TEXT NOT NULL,
      FOREIGN KEY (book_id) REFERENCES books(id),
      FOREIGN KEY (version_id) REFERENCES bible_versions(id)
    );
  `);

  // FTS5 virtual table for search
  db.exec(`
    CREATE VIRTUAL TABLE verses_fts USING fts5(
      book_id UNINDEXED,
      chapter_number UNINDEXED,
      verse_number UNINDEXED,
      text,
      version_id UNINDEXED,
      content='verses',
      content_rowid='id'
    );
  `);

  // Metadata table
  db.exec(`
    CREATE TABLE metadata (
      key TEXT PRIMARY KEY,
      value TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Create indexes for performance
  db.exec(`
    CREATE INDEX idx_verses_book_chapter ON verses(book_id, chapter_number);
    CREATE INDEX idx_verses_reference ON verses(book_id, chapter_number, verse_number);
    CREATE INDEX idx_verses_version ON verses(version_id);
    CREATE INDEX idx_chapters_book ON chapters(book_id);
    CREATE INDEX idx_highlights_verse ON highlights(book_id, chapter_number, verse_number);
    CREATE INDEX idx_notes_verse ON notes(book_id, chapter_number, verse_number);
    CREATE INDEX idx_footnotes_verse ON footnotes(book_id, chapter_number, verse_number);
    CREATE INDEX idx_footnotes_type ON footnotes(footnote_type);
    CREATE INDEX idx_books_testament ON books(testament);
    CREATE INDEX idx_books_order ON books(book_order);
    CREATE INDEX idx_books_code ON books(code);
    CREATE INDEX idx_books_version ON books(version_id);
  `);
}

/**
 * Inserts Bible versions first
 */
function insertBibleVersions(db, sources) {
  const insert = db.prepare(`
    INSERT OR REPLACE INTO bible_versions (id, name, full_name, language, description, is_default)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  const transaction = db.transaction((sources) => {
    let isFirst = true;
    for (const [id, source] of Object.entries(sources)) {
      insert.run(
        source.abbreviation || id.toUpperCase(),
        source.abbreviation || id.toUpperCase(),
        source.name,
        source.language || 'en',
        `${source.name} - ${source.format.toUpperCase()} format`,
        isFirst ? 1 : 0
      );
      isFirst = false;
    }
  });

  transaction(sources);
}

/**
 * Inserts book data with proper ID mapping and localized names
 */
function insertBooks(db, books, bookNames) {
  const bookOrder = [
    'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA',
    '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO',
    'ECC', 'SNG', 'ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO',
    'OBA', 'JON', 'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL',
    'MAT', 'MRK', 'LUK', 'JHN', 'ACT', 'ROM', '1CO', '2CO', 'GAL', 'EPH',
    'PHP', 'COL', '1TH', '2TH', '1TI', '2TI', 'TIT', 'PHM', 'HEB', 'JAS',
    '1PE', '2PE', '1JN', '2JN', '3JN', 'JUD', 'REV'
  ];

  const bookNames_en = {
    'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numbers', 'DEU': 'Deuteronomy',
    'JOS': 'Joshua', 'JDG': 'Judges', 'RUT': 'Ruth', '1SA': '1 Samuel', '2SA': '2 Samuel',
    '1KI': '1 Kings', '2KI': '2 Kings', '1CH': '1 Chronicles', '2CH': '2 Chronicles',
    'EZR': 'Ezra', 'NEH': 'Nehemiah', 'EST': 'Esther', 'JOB': 'Job', 'PSA': 'Psalms',
    'PRO': 'Proverbs', 'ECC': 'Ecclesiastes', 'SNG': 'Song of Solomon', 'ISA': 'Isaiah',
    'JER': 'Jeremiah', 'LAM': 'Lamentations', 'EZK': 'Ezekiel', 'DAN': 'Daniel',
    'HOS': 'Hosea', 'JOL': 'Joel', 'AMO': 'Amos', 'OBA': 'Obadiah', 'JON': 'Jonah',
    'MIC': 'Micah', 'NAM': 'Nahum', 'HAB': 'Habakkuk', 'ZEP': 'Zephaniah', 'HAG': 'Haggai',
    'ZEC': 'Zechariah', 'MAL': 'Malachi',
    'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John', 'ACT': 'Acts',
    'ROM': 'Romans', '1CO': '1 Corinthians', '2CO': '2 Corinthians', 'GAL': 'Galatians',
    'EPH': 'Ephesians', 'PHP': 'Philippians', 'COL': 'Colossians', '1TH': '1 Thessalonians',
    '2TH': '2 Thessalonians', '1TI': '1 Timothy', '2TI': '2 Timothy', 'TIT': 'Titus',
    'PHM': 'Philemon', 'HEB': 'Hebrews', 'JAS': 'James', '1PE': '1 Peter', '2PE': '2 Peter',
    '1JN': '1 John', '2JN': '2 John', '3JN': '3 John', 'JUD': 'Jude', 'REV': 'Revelation'
  };

  // Group book names by version and code for efficient lookup
  const bookNamesMap = new Map();
  for (const bookName of bookNames) {
    const key = `${bookName.version_id}_${bookName.book_code}`;
    bookNamesMap.set(key, bookName);
  }

  const insert = db.prepare(`
    INSERT OR REPLACE INTO books (code, version_id, name, abbreviation, short_name, long_name, alt_name, testament, book_order)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  // Create book code to ID mapping for later use
  const bookCodeToId = new Map();

  const transaction = db.transaction((books) => {
    for (const [code, book] of books) {
      // Get localized names for this book and version
      const key = `${book.version_id}_${code}`;
      const localizedNames = bookNamesMap.get(key);

      const orderNumber = bookOrder.indexOf(code) + 1 || 999;
      const testament = orderNumber <= 39 ? 'OT' : 'NT';
      const name = bookNames_en[code] || book.name || code;

      // Use localized names if available, otherwise use defaults
      const abbreviation = localizedNames?.abbreviation || code;
      const shortName = localizedNames?.short_name || name;
      const longName = localizedNames?.long_name || name;
      const altName = localizedNames?.alt_name || null;

      const result = insert.run(
        code,
        book.version_id,
        name,
        abbreviation,
        shortName,
        longName,
        altName,
        testament,
        orderNumber
      );

      const bookKey = `${code}_${book.version_id}`;
      bookCodeToId.set(bookKey, result.lastInsertRowid);
    }
  });

  transaction(books);

  // Store mapping for use in other functions
  db._bookCodeToId = bookCodeToId;
  return bookCodeToId;
}

/**
 * Inserts chapter data with proper foreign keys
 */
function insertChapters(db, chapters, bookCodeToId) {
  const insert = db.prepare(`
    INSERT OR REPLACE INTO chapters (book_id, chapter_number, verse_count)
    VALUES (?, ?, ?)
  `);

  const transaction = db.transaction((chapters) => {
    for (const [key, chapter] of chapters) {
      const bookKey = `${chapter.book_code}_${chapter.version_id}`;
      const bookId = bookCodeToId.get(bookKey);
      if (bookId) {
        insert.run(bookId, chapter.chapter_number, chapter.verse_count);
      }
    }
  });

  transaction(chapters);

  // Update chapter counts in books table
  db.exec(`
    UPDATE books SET chapter_count = (
      SELECT COUNT(*) FROM chapters WHERE chapters.book_id = books.id
    )
  `);
}

/**
 * Inserts verse data with proper foreign keys
 */
function insertVerses(db, verses, bookCodeToId) {
  const insert = db.prepare(`
    INSERT OR REPLACE INTO verses (book_id, chapter_number, verse_number, text, version_id)
    VALUES (?, ?, ?, ?, ?)
  `);

  const transaction = db.transaction((verses) => {
    for (const verse of verses) {
      const bookKey = `${verse.book_code}_${verse.version_id}`;
      const bookId = bookCodeToId.get(bookKey);
      if (bookId) {
        insert.run(bookId, verse.chapter, verse.verse, verse.text, verse.version_id);
      }
    }
  });

  transaction(verses);
}

/**
 * Inserts footnote data with proper foreign keys
 */
function insertFootnotes(db, footnotes, bookCodeToId) {
  if (!footnotes || footnotes.length === 0) return;

  const insert = db.prepare(`
    INSERT OR REPLACE INTO footnotes (book_id, chapter_number, verse_number, version_id, footnote_type, caller, content)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);

  const transaction = db.transaction((footnotes) => {
    for (const footnote of footnotes) {
      const bookKey = `${footnote.book_code}_${footnote.version_id}`;
      const bookId = bookCodeToId.get(bookKey);
      if (bookId) {
        insert.run(
          bookId,
          footnote.chapter,
          footnote.verse,
          footnote.version_id,
          footnote.type || 'footnote',
          footnote.caller || '',
          footnote.content
        );
      }
    }
  });

  transaction(footnotes);
}

/**
 * Builds FTS5 search index
 */
function buildSearchIndex(db) {
  // Populate FTS5 table
  db.exec(`
    INSERT INTO verses_fts(rowid, book_id, chapter_number, verse_number, text, version_id)
    SELECT id, book_id, chapter_number, verse_number, text, version_id FROM verses;
  `);

  // Create FTS5 triggers for automatic updates
  db.exec(`
    CREATE TRIGGER verses_fts_insert AFTER INSERT ON verses BEGIN
      INSERT INTO verses_fts(rowid, book_id, chapter_number, verse_number, text, version_id)
      VALUES (new.id, new.book_id, new.chapter_number, new.verse_number, new.text, new.version_id);
    END;
  `);

  db.exec(`
    CREATE TRIGGER verses_fts_delete AFTER DELETE ON verses BEGIN
      INSERT INTO verses_fts(verses_fts, rowid, book_id, chapter_number, verse_number, text, version_id)
      VALUES ('delete', old.id, old.book_id, old.chapter_number, old.verse_number, old.text, old.version_id);
    END;
  `);

  db.exec(`
    CREATE TRIGGER verses_fts_update AFTER UPDATE ON verses BEGIN
      INSERT INTO verses_fts(verses_fts, rowid, book_id, chapter_number, verse_number, text, version_id)
      VALUES ('delete', old.id, old.book_id, old.chapter_number, old.verse_number, old.text, old.version_id);
      INSERT INTO verses_fts(rowid, book_id, chapter_number, verse_number, text, version_id)
      VALUES (new.id, new.book_id, new.chapter_number, new.verse_number, new.text, new.version_id);
    END;
  `);
}

/**
 * Optimizes database for performance
 */
function optimizeDatabase(db) {
  db.exec('VACUUM;');
  db.exec('ANALYZE;');
  db.exec('PRAGMA optimize;');

  // Set pragmas for optimal performance
  db.exec('PRAGMA journal_mode = WAL;');
  db.exec('PRAGMA synchronous = NORMAL;');
  db.exec('PRAGMA cache_size = 10000;');
  db.exec('PRAGMA temp_store = memory;');
}

/**
 * Inserts pipeline metadata
 */
function insertMetadata(db, parsedData) {
  const insert = db.prepare('INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)');

  const stats = {
    version: '1.0.0',
    built_at: new Date().toISOString(),
    book_count: parsedData.books.size,
    chapter_count: parsedData.chapters.size,
    verse_count: parsedData.verses.length,
    versions: [...new Set(parsedData.verses.map(v => v.version_id))].join(','),
    checksum: crypto.createHash('sha256')
      .update(JSON.stringify(Array.from(parsedData.books.keys()).sort()))
      .digest('hex')
  };

  for (const [key, value] of Object.entries(stats)) {
    insert.run(key, String(value));
  }
}

module.exports = { buildDatabase };
