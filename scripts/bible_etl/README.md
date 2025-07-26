# Bible ETL Pipeline

An autonomous, idempotent ETL pipeline that downloads, parses, and builds a search-optimized SQLite database from multiple Bible formats for Flutter Bible applications.

## 🎯 Agent Instructions

This ETL pipeline is designed for autonomous execution. The system is **idempotent** - safe to run multiple times without data corruption.

### Quick Start
```bash
cd scripts/bible_etl
npm install
npm run build
```

### Pipeline Commands
```bash
npm run build          # Full ETL pipeline (download → parse → build → deploy)
npm run download       # Download sources only
npm run parse          # Parse downloaded files only
npm run deploy         # Deploy database to Flutter assets only
npm run verify         # Verify generated database integrity
npm run clean          # Clean downloads and generated files
npm run test           # Build + verify pipeline
```

## 🏗️ Architecture

### Input
- **Configuration**: `bible_sources.json` - Declarative source definitions
- **Downloads**: Auto-downloaded to `downloads/{id}/` (gitignored)

### Processing
1. **Download**: Fetch archives/files from URLs with integrity checking
2. **Parse**: Multi-format parser (USFM, USFX, USX, OSIS, plain text)
3. **Transform**: Normalize to unified data structure
4. **Load**: Build optimized SQLite with FTS5 search
5. **Deploy**: Copy to Flutter `assets/bibles/`

### Output
- **Database**: `bible.db` → `../../assets/bibles/bible.db`
- **Schema**: Matches Flutter entity classes exactly
- **Search**: FTS5 virtual tables for full-text search
- **Metadata**: Pipeline stats and checksums

## 📊 Database Schema

The database schema is synchronized with Flutter entities:

```sql
-- Bible versions
CREATE TABLE bible_versions (
  id TEXT PRIMARY KEY,           -- BibleVersion.id
  name TEXT NOT NULL,            -- BibleVersion.name
  full_name TEXT NOT NULL,       -- BibleVersion.fullName
  language TEXT NOT NULL,        -- BibleVersion.language
  description TEXT NOT NULL,     -- BibleVersion.description
  is_default INTEGER DEFAULT 0   -- BibleVersion.isDefault
);

-- Books with proper ordering
CREATE TABLE books (
  id INTEGER PRIMARY KEY,        -- Book.id
  name TEXT NOT NULL,            -- Book.name
  name_local TEXT NOT NULL,      -- Book.nameLocal
  abbreviation TEXT NOT NULL,    -- Book.abbreviation
  chapter_count INTEGER DEFAULT 0, -- Book.chapterCount
  testament TEXT CHECK (testament IN ('OT', 'NT')), -- Book.testament
  book_order INTEGER NOT NULL   -- Book.order
);

-- Chapters linked to books
CREATE TABLE chapters (
  id INTEGER PRIMARY KEY,        -- Chapter.id
  book_id INTEGER NOT NULL,      -- Chapter.bookId
  chapter_number INTEGER NOT NULL, -- Chapter.chapterNumber
  verse_count INTEGER DEFAULT 0, -- Chapter.verseCount
  FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Verses with full metadata
CREATE TABLE verses (
  id INTEGER PRIMARY KEY,        -- Verse.id
  book_id INTEGER NOT NULL,      -- Verse.bookId
  chapter_number INTEGER NOT NULL, -- Verse.chapterNumber
  verse_number INTEGER NOT NULL, -- Verse.verseNumber
  text TEXT NOT NULL,            -- Verse.text
  version_id TEXT NOT NULL,      -- Verse.versionId
  FOREIGN KEY (book_id) REFERENCES books(id),
  FOREIGN KEY (version_id) REFERENCES bible_versions(id)
);

-- FTS5 virtual table for search
CREATE VIRTUAL TABLE verses_fts USING fts5(
  book_id UNINDEXED,
  chapter_number UNINDEXED,
  verse_number UNINDEXED,
  text,                    -- Searchable content
  version_id UNINDEXED,
  content='verses',
  content_rowid='id'
);

-- User annotations (highlights, notes)
CREATE TABLE highlights (...);  -- Highlight entity
CREATE TABLE notes (...);       -- Note entity
```

## 🔧 Configuration

### Adding Bible Sources

Edit `bible_sources.json`:

```json
{
  "source_id": {
    "name": "Version Name",
    "format": "usfm|usfx|usx|osis|text",
    "url": "https://example.com/bible.zip",
    "language": "en",
    "abbreviation": "VER"
  }
}
```

### Supported Formats

- **USFM** (Unified Standard Format Markers): `.usfm`, `.sfm`
- **USFX** (USFM XML): `.usfx`, `.xml`
- **USX** (Scripture XML): `.usx`
- **OSIS** (Open Scripture Information Standard): `.osis`, `.xml`
- **Plain Text**: Custom text formats

## 🚀 Deployment

The pipeline automatically:

1. **Generates Database**: `bible.db` with optimized schema
2. **Updates Assets**: Copies to `../../assets/bibles/bible.db`
3. **Updates Pubspec**: Adds assets section if needed
4. **Creates Metadata**: Database statistics and info

## ✅ Verification

The verification system ensures:

- **Schema Integrity**: Tables match Flutter entities
- **Data Consistency**: No orphaned records, valid relationships
- **Search Functionality**: FTS5 indexes work correctly
- **Performance**: Query benchmarks within acceptable limits

```bash
npm run verify                    # Verify local bible.db
npm run verify-deployed          # Verify deployed database
```

## 🔄 Idempotency

The pipeline is fully idempotent:

- **Downloads**: Checksums prevent re-downloading unchanged files
- **Database**: `INSERT OR REPLACE` prevents duplicates
- **Assets**: Safe to overwrite existing files
- **Schema**: `IF NOT EXISTS` prevents conflicts

Running the pipeline multiple times with the same input produces identical output.

## 📈 Performance

- **Indexes**: Optimized for Bible navigation patterns
- **FTS5**: Full-text search with ranking
- **Transactions**: Bulk inserts for speed
- **Pragmas**: SQLite optimizations for mobile

## 🛠️ Development

### File Structure
```
scripts/bible_etl/
├── README.md              # This file
├── package.json           # Dependencies and scripts
├── bible_sources.json     # Source configurations
├── index.js              # Main pipeline orchestrator
├── verify.js             # Database verification
├── src/
│   ├── downloader.js     # Multi-source downloader
│   ├── parser.js         # Multi-format parser
│   ├── database.js       # SQLite builder
│   └── deployer.js       # Asset deployment
├── downloads/            # Downloaded files (gitignored)
└── .gitignore           # Ignore downloads and generated files
```

### Error Handling

The pipeline includes comprehensive error handling:
- Network failures with retry logic
- Format validation and parsing errors
- Database constraint violations
- File system permission issues

All errors are logged with context for debugging.

## 📝 Logs

Pipeline execution produces detailed logs:

```
🚀 Starting Bible ETL Pipeline...
📥 Downloading Bible sources...
  📦 Processing King James Version (kjv)...
    📥 Downloading from https://example.com/kjv.zip...
    📂 Extracting archive...
    ✓ Downloaded and extracted
📖 Parsing Bible files...
  📖 Parsing King James Version...
    ✓ Parsed 66 books, 1189 chapters, 31102 verses
🗄️ Building SQLite database...
    🏗️ Creating database schema...
    📋 Inserting Bible versions...
    📚 Inserting books...
    📖 Inserting chapters...
    📝 Inserting verses...
    🔍 Building search index...
    🔧 Optimizing database...
    💾 Creating metadata...
    ✅ Database created: ./bible.db
🚀 Deploying to Flutter assets...
    📱 Database deployed to ../../assets/bibles/bible.db
    📝 Updated pubspec.yaml assets
    📊 Generated database info file
✅ ETL Pipeline completed successfully!
```

This pipeline is ready for autonomous execution and integration into CI/CD workflows.
