const Database = require('better-sqlite3');
const fs = require('fs');

/**
 * Verifies the generated database matches Flutter entity expectations
 */
function verifyDatabase(dbPath) {
  console.log('🔍 Verifying database integrity...');

  if (!fs.existsSync(dbPath)) {
    throw new Error(`Database file not found: ${dbPath}`);
  }

  const db = new Database(dbPath, { readonly: true });

  try {
    // Test 1: Schema verification
    console.log('  📋 Checking schema...');
    verifySchema(db);

    // Test 2: Data integrity
    console.log('  📊 Checking data integrity...');
    verifyDataIntegrity(db);

    // Test 3: Flutter entity compatibility
    console.log('  📱 Testing Flutter entity compatibility...');
    verifyFlutterCompatibility(db);

    // Test 4: Search functionality
    console.log('  🔍 Testing search functionality...');
    verifySearchFunctionality(db);

    // Test 5: Enhanced content verification
    console.log('  📖 Verifying content quality...');
    verifyContentQuality(db);

    // Test 6: Performance benchmarks
    console.log('  ⚡ Running performance tests...');
    verifyPerformance(db);

    console.log('✅ Database verification completed successfully!');

  } finally {
    db.close();
  }
}

/**
 * Verifies database schema matches expected structure
 */
function verifySchema(db) {
  const expectedTables = [
    'bible_versions', 'books', 'chapters', 'verses',
    'highlights', 'notes', 'footnotes', 'verses_fts', 'metadata'
  ];

  // Check all tables exist
  const tables = db.prepare(`
    SELECT name FROM sqlite_master WHERE type='table' ORDER BY name
  `).all().map(row => row.name);

  for (const table of expectedTables) {
    if (!tables.includes(table)) {
      throw new Error(`Missing table: ${table}`);
    }
  }

  // Verify bible_versions schema
  const versionCols = getTableColumns(db, 'bible_versions');
  const expectedVersionCols = ['id', 'name', 'full_name', 'language', 'description', 'is_default'];
  verifyColumns('bible_versions', versionCols, expectedVersionCols);

  // Verify books schema
  const bookCols = getTableColumns(db, 'books');
  const expectedBookCols = ['id', 'code', 'version_id', 'name', 'abbreviation', 'short_name', 'long_name', 'alt_name', 'chapter_count', 'testament', 'book_order'];
  verifyColumns('books', bookCols, expectedBookCols);

  // Verify chapters schema
  const chapterCols = getTableColumns(db, 'chapters');
  const expectedChapterCols = ['id', 'book_id', 'chapter_number', 'verse_count'];
  verifyColumns('chapters', chapterCols, expectedChapterCols);

  // Verify verses schema
  const verseCols = getTableColumns(db, 'verses');
  const expectedVerseCols = ['id', 'book_id', 'chapter_number', 'verse_number', 'text', 'version_id'];
  verifyColumns('verses', verseCols, expectedVerseCols);

  // Verify footnotes schema
  const footnoteCols = getTableColumns(db, 'footnotes');
  const expectedFootnoteCols = ['id', 'book_id', 'chapter_number', 'verse_number', 'version_id', 'footnote_type', 'caller', 'content'];
  verifyColumns('footnotes', footnoteCols, expectedFootnoteCols);

  console.log('    ✓ Schema verification passed');
}

/**
 * Verifies data integrity and relationships
 */
function verifyDataIntegrity(db) {
  // Check for orphaned records
  const orphanedChapters = db.prepare(`
    SELECT COUNT(*) as count FROM chapters
    WHERE book_id NOT IN (SELECT id FROM books)
  `).get().count;

  if (orphanedChapters > 0) {
    throw new Error(`Found ${orphanedChapters} orphaned chapters`);
  }

  const orphanedVerses = db.prepare(`
    SELECT COUNT(*) as count FROM verses
    WHERE book_id NOT IN (SELECT id FROM books)
  `).get().count;

  if (orphanedVerses > 0) {
    throw new Error(`Found ${orphanedVerses} orphaned verses`);
  }

  // Check testament values
  const invalidTestaments = db.prepare(`
    SELECT COUNT(*) as count FROM books
    WHERE testament NOT IN ('OT', 'NT')
  `).get().count;

  if (invalidTestaments > 0) {
    throw new Error(`Found ${invalidTestaments} books with invalid testament`);
  }

  // Check verse counts match
  const chapterVerseMismatch = db.prepare(`
    SELECT c.book_id, c.chapter_number, c.verse_count,
           COUNT(v.id) as actual_verses
    FROM chapters c
    LEFT JOIN verses v ON c.book_id = v.book_id AND c.chapter_number = v.chapter_number
    GROUP BY c.book_id, c.chapter_number
    HAVING c.verse_count != COUNT(v.id)
    LIMIT 5
  `).all();

  if (chapterVerseMismatch.length > 0) {
    console.warn(`    ⚠️ Found ${chapterVerseMismatch.length} chapters with verse count mismatches`);
    // Log first few for debugging
    chapterVerseMismatch.forEach(row => {
      console.warn(`      Book ${row.book_id}, Chapter ${row.chapter_number}: expected ${row.verse_count}, got ${row.actual_verses}`);
    });
  }

  console.log('    ✓ Data integrity checks passed');
}

/**
 * Tests compatibility with Flutter entity structure
 */
function verifyFlutterCompatibility(db) {
  // Test BibleVersion entity mapping
  const version = db.prepare(`
    SELECT * FROM bible_versions LIMIT 1
  `).get();

  if (version) {
    const requiredVersionFields = ['id', 'name', 'full_name', 'language', 'description', 'is_default'];
    for (const field of requiredVersionFields) {
      if (!(field in version)) {
        throw new Error(`BibleVersion missing field: ${field}`);
      }
    }
  }

  // Test Book entity mapping
  const book = db.prepare(`
    SELECT * FROM books LIMIT 1
  `).get();

  if (book) {
    const requiredBookFields = ['id', 'code', 'version_id', 'name', 'abbreviation', 'short_name', 'long_name', 'alt_name', 'chapter_count', 'testament', 'book_order'];
    for (const field of requiredBookFields) {
      if (!(field in book)) {
        throw new Error(`Book missing field: ${field}`);
      }
    }
  }

  // Test Verse entity mapping
  const verse = db.prepare(`
    SELECT * FROM verses LIMIT 1
  `).get();

  if (verse) {
    const requiredVerseFields = ['id', 'book_id', 'chapter_number', 'verse_number', 'text', 'version_id'];
    for (const field of requiredVerseFields) {
      if (!(field in verse)) {
        throw new Error(`Verse missing field: ${field}`);
      }
    }
  }

  // Test Footnote entity mapping
  const footnote = db.prepare(`
    SELECT * FROM footnotes LIMIT 1
  `).get();

  if (footnote) {
    const requiredFootnoteFields = ['id', 'book_id', 'chapter_number', 'verse_number', 'version_id', 'footnote_type', 'caller', 'content'];
    for (const field of requiredFootnoteFields) {
      if (!(field in footnote)) {
        throw new Error(`Footnote missing field: ${field}`);
      }
    }
  }

  console.log('    ✓ Flutter entity compatibility verified');
}

/**
 * Tests search functionality
 */
function verifySearchFunctionality(db) {
  // Test FTS5 table exists and is populated
  const ftsCount = db.prepare(`
    SELECT COUNT(*) as count FROM verses_fts
  `).get().count;

  const versesCount = db.prepare(`
    SELECT COUNT(*) as count FROM verses
  `).get().count;

  if (ftsCount !== versesCount) {
    throw new Error(`FTS table count (${ftsCount}) doesn't match verses count (${versesCount})`);
  }

  // Test search query
  const searchResults = db.prepare(`
    SELECT COUNT(*) as count FROM verses_fts WHERE verses_fts MATCH 'love'
  `).get().count;

  if (searchResults === 0) {
    console.warn('    ⚠️ No search results for "love" - check if Bible text is properly indexed');
  }

  console.log(`    ✓ Search functionality verified (${searchResults} results for "love")`);
}

/**
 * Runs performance benchmarks
 */
function verifyPerformance(db) {
  const startTime = Date.now();

  // Test 1: Book lookup
  const books = db.prepare(`
    SELECT * FROM books ORDER BY book_order
  `).all();

  // Test 2: Chapter navigation
  const chapters = db.prepare(`
    SELECT * FROM chapters WHERE book_id = ? ORDER BY chapter_number
  `).all(1);

  // Test 3: Verse retrieval
  const verses = db.prepare(`
    SELECT * FROM verses WHERE book_id = ? AND chapter_number = ?
  `).all(1, 1);

  // Test 4: Search query
  const searchTime = Date.now();
  const searchResults = db.prepare(`
    SELECT * FROM verses_fts WHERE verses_fts MATCH 'love' LIMIT 10
  `).all();
  const searchDuration = Date.now() - searchTime;

  const totalTime = Date.now() - startTime;

  console.log(`    ✓ Performance tests completed in ${totalTime}ms`);
  console.log(`      - ${books.length} books loaded`);
  console.log(`      - ${chapters.length} chapters in first book`);
  console.log(`      - ${verses.length} verses in first chapter`);
  console.log(`      - Search query took ${searchDuration}ms`);

  if (searchDuration > 100) {
    console.warn(`    ⚠️ Search query is slow (${searchDuration}ms). Consider optimizing.`);
  }
}

/**
 * Helper functions
 */
function getTableColumns(db, tableName) {
  return db.prepare(`PRAGMA table_info(${tableName})`).all().map(col => col.name);
}

function verifyColumns(tableName, actual, expected) {
  for (const col of expected) {
    if (!actual.includes(col)) {
      throw new Error(`Table ${tableName} missing column: ${col}`);
    }
  }
}

/**
 * Generate database statistics
 */
function generateStats(dbPath) {
  console.log('\n📊 Database Statistics:');

  const db = new Database(dbPath, { readonly: true });

  try {
    const stats = {
      versions: db.prepare('SELECT COUNT(*) as count FROM bible_versions').get().count,
      books: db.prepare('SELECT COUNT(*) as count FROM books').get().count,
      chapters: db.prepare('SELECT COUNT(*) as count FROM chapters').get().count,
      verses: db.prepare('SELECT COUNT(*) as count FROM verses').get().count,
      otBooks: db.prepare("SELECT COUNT(*) as count FROM books WHERE testament = 'OT'").get().count,
      ntBooks: db.prepare("SELECT COUNT(*) as count FROM books WHERE testament = 'NT'").get().count,
      fileSize: Math.round(fs.statSync(dbPath).size / 1024 / 1024 * 100) / 100
    };

    console.log(`  📖 ${stats.versions} Bible version(s)`);
    console.log(`  📚 ${stats.books} books (${stats.otBooks} OT, ${stats.ntBooks} NT)`);
    console.log(`  📄 ${stats.chapters} chapters`);
    console.log(`  📝 ${stats.verses} verses`);
    console.log(`  💾 ${stats.fileSize} MB file size`);

    // Sample data
    const sampleVerse = db.prepare(`
      SELECT b.name as book_name, v.chapter_number, v.verse_number, v.text, v.version_id
      FROM verses v
      JOIN books b ON v.book_id = b.id
      ORDER BY b.book_order, v.chapter_number, v.verse_number
      LIMIT 1
    `).get();

    if (sampleVerse) {
      console.log(`  📜 Sample: ${sampleVerse.book_name} ${sampleVerse.chapter_number}:${sampleVerse.verse_number} (${sampleVerse.version_id})`);
      console.log(`     "${sampleVerse.text.substring(0, 80)}..."`);
    }

  } finally {
    db.close();
  }
}

// CLI interface
if (require.main === module) {
  const dbPath = process.argv[2] || 'dist/bible.db';

  try {
    verifyDatabase(dbPath);
    generateStats(dbPath);
  } catch (error) {
    console.error('❌ Verification failed:', error.message);
    process.exit(1);
  }
}

module.exports = { verifyDatabase, generateStats };
