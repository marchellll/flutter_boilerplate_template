const fs = require('fs');
const path = require('path');
const { parseUSFM, parseUSFX, parseUSX, parseOSIS, parseText } = require('./parsers');

/**
 * Parses all Bible sources into normalized data structure
 */
async function parseAllSources(sources, downloadsDir) {
  const allData = {
    books: new Map(),
    chapters: new Map(),
    verses: [],
    footnotes: [],
    bookNames: []
  };

  for (const [id, source] of Object.entries(sources)) {
    console.log(`  📖 Parsing ${source.name}...`);
    const sourceData = await parseSource(id, source, downloadsDir);
    console.log(`    📊 ${source.name}: ${sourceData.verses.length} verses, ${sourceData.books.size} books`);
    mergeSourceData(allData, sourceData, id);
    console.log(`    📈 After merge: ${allData.verses.length} total verses, ${allData.books.size} total books`);
  }

  console.log(`📊 Final combined data: ${allData.verses.length} verses, ${allData.footnotes.length} footnotes, ${allData.books.size} books`);

  return allData;
}

/**
 * Parses a single Bible source based on format
 */
async function parseSource(id, source, downloadsDir) {
  const sourceDir = path.join(downloadsDir, id);

  if (!fs.existsSync(sourceDir)) {
    throw new Error(`Source directory not found: ${sourceDir}`);
  }

  switch (source.format.toLowerCase()) {
    case 'usfm':
      return parseUSFM(sourceDir, source);
    case 'usfx':
      return parseUSFX(sourceDir, source);
    case 'usx':
      return parseUSX(sourceDir, source);
    case 'osis':
      return parseOSIS(sourceDir, source);
    case 'text':
      return parseText(sourceDir, source);
    default:
      throw new Error(`Unsupported format: ${source.format}`);
  }
}

/**
 * Merges source data into combined dataset
 */
function mergeSourceData(allData, sourceData, versionId) {
  // Merge books - use compound key to allow multiple versions
  for (const [code, book] of sourceData.books) {
    const bookKey = `${code}_${book.version_id}`;
    allData.books.set(bookKey, book);
  }

  // Merge chapters
  for (const [key, chapter] of sourceData.chapters) {
    if (!allData.chapters.has(key)) {
      allData.chapters.set(key, chapter);
    }
  }

  // Add verses
  allData.verses.push(...sourceData.verses);
  
  // Add footnotes
  if (sourceData.footnotes) {
    allData.footnotes.push(...sourceData.footnotes);
  }
  
  // Add book names
  if (sourceData.bookNames) {
    allData.bookNames.push(...sourceData.bookNames);
  }
}

module.exports = { parseAllSources, parseSource };
