# USFX Parser Output Structure Documentation

This document describes the data structure returned by the USFX parser (`parseUSFX` function) in the Bible ETL pipeline.

## Overview

The parser returns a structured object containing all the parsed Bible data from USFX format files. The output is designed to be normalized and ready for database insertion.

## Top-Level Structure

```typescript
interface ParserOutput {
  books: Map<string, BookData>;
  chapters: Map<string, ChapterData>;
  verses: VerseData[];
  footnotes: FootnoteData[];
  bookNames: BookNameData[];
}
```

## Data Structures

### 1. BookData

Represents information about each book of the Bible.

```typescript
interface BookData {
  code: string;           // Normalized book code (e.g., "GEN", "MAT", "REV")
  name: string;           // Full book name (e.g., "Genesis", "Matthew", "Revelation")
  testament: string;      // "OT" for Old Testament, "NT" for New Testament
  version_id: string;     // Version abbreviation (e.g., "KJV", "TSI")
}
```

**Example:**
```javascript
{
  code: "GEN",
  name: "Genesis",
  testament: "OT",
  version_id: "KJV"
}
```

**Map Key:** The book code (e.g., `"GEN"`)

### 2. ChapterData

Represents metadata about each chapter in each book.

```typescript
interface ChapterData {
  book_code: string;      // Book code this chapter belongs to
  chapter_number: number; // Chapter number (1-based)
  verse_count: number;    // Total number of verses in this chapter
}
```

**Example:**
```javascript
{
  book_code: "GEN",
  chapter_number: 1,
  verse_count: 31
}
```

**Map Key:** `"{book_code}_{chapter_number}"` (e.g., `"GEN_1"`)

### 3. VerseData

Represents individual Bible verses with their text content.

```typescript
interface VerseData {
  book_code: string;    // Book code (e.g., "GEN")
  chapter: number;      // Chapter number (1-based)
  verse: number;        // Verse number (1-based)
  text: string;         // Cleaned verse text content
  version_id: string;   // Version abbreviation
}
```

**Example:**
```javascript
{
  book_code: "GEN",
  chapter: 1,
  verse: 1,
  text: "In the beginning God created the heaven and the earth.",
  version_id: "KJV"
}
```

### 4. FootnoteData

Represents footnotes and cross-references extracted from the USFX markup.

```typescript
interface FootnoteData {
  book_code: string;    // Book code where footnote appears
  chapter: number;      // Chapter number
  verse: number;        // Verse number
  version_id: string;   // Version abbreviation
  type: string;         // "footnote" or "cross_reference"
  caller: string;       // Footnote marker/caller (e.g., "a", "1", "*")
  content: string;      // Footnote text content
}
```

**Example:**
```javascript
{
  book_code: "GEN",
  chapter: 1,
  verse: 1,
  version_id: "KJV",
  type: "footnote",
  caller: "a",
  content: "Hebrew: In the beginning of God's creating"
}
```

### 5. BookNameData

Represents localized book names and abbreviations from BookNames.xml.

```typescript
interface BookNameData {
  book_code: string;      // Normalized book code
  language: string;       // Language code (e.g., "en", "id", "unknown")
  abbreviation: string;   // Short abbreviation
  short_name: string;     // Short display name
  long_name: string;      // Full display name
  alt_name: string | null; // Alternative name (if available)
}
```

**Example:**
```javascript
{
  book_code: "GEN",
  language: "en",
  abbreviation: "Gen",
  short_name: "Genesis",
  long_name: "The Book of Genesis",
  alt_name: null
}
```

## Data Flow

1. **USFX Files** → Parser reads XML files with `.usfx.xml` extension
2. **BookNames.xml** → Parser extracts localized book names and abbreviations
3. **Milestone Processing** → Parser uses USFX milestone approach to extract verse boundaries
4. **Content Extraction** → Parser extracts verse text, footnotes, and cross-references
5. **Normalization** → Data is cleaned and normalized into the output structure

## Key Features

### Milestone-Based Parsing
The parser uses USFX's milestone approach where verse boundaries are marked with `<v bcv="..."/>` elements, allowing for more accurate verse extraction compared to container-based approaches.

### Footnote Structure Support
Extracts structured footnote content including:
- `<fr>` - Footnote reference
- `<ft>` - Footnote text
- `<fk>` - Footnote keywords
- `<fq>` - Footnote quotations

### Cross-Reference Support
Extracts cross-reference data including:
- `<xo>` - Cross-reference origin
- `<xt>` - Cross-reference targets
- `<xk>` - Cross-reference keywords
- `<xq>` - Cross-reference quotations

### Theological Markup Preservation
Preserves text content from theological markup elements:
- `<nd>` - Name of deity
- `<wj>` - Words of Jesus
- `<pn>` - Proper names
- `<k>` - Keywords
- `<add>` - Added text
- `<qt>` - Quoted text
- `<tl>` - Transliterated text

## Usage in ETL Pipeline

The parser output is consumed by:

1. **Database Builder** - Converts Maps and arrays into SQLite database tables
2. **Chapter Calculator** - Uses verse data to calculate chapter verse counts
3. **Footnote Processor** - Stores footnote data as separate table entries
4. **Book Metadata** - Populates book information tables

## Error Handling

The parser includes robust error handling:
- Skips malformed book entries
- Warns about missing BookNames.xml files
- Handles missing or invalid verse markers
- Continues processing even if individual books fail

## Performance Considerations

- Uses Maps for O(1) lookup of books and chapters
- Processes files sequentially to avoid memory issues
- Provides progress logging for large Bible datasets
- Efficiently handles large XML files using cheerio streaming
