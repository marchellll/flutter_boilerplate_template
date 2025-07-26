const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const { normalizeBookCode, getBookName, getTestament, cleanVerseText } = require('./utils');

/**
 * Parses USFX format files using milestone-based approach
 *
 * @param {string} sourceDir - Directory containing USFX files
 * @param {Object} source - Source configuration object with name, abbreviation, etc.
 * @returns {Object} Parsed data structure:
 *   {
 *     books: Map<string, {code, name, testament, version_id}>,
 *     chapters: Map<string, {book_code, chapter_number, verse_count}>,
 *     verses: Array<{book_code, chapter, verse, text, version_id}>,
 *     footnotes: Array<{book_code, chapter, verse, version_id, type, caller, content}>,
 *     bookNames: Array<{book_code, language, abbreviation, short_name, long_name, alt_name}>
 *   }
 */
function parseUSFX(sourceDir, source) {
  const data = { books: new Map(), chapters: new Map(), verses: [], footnotes: [], bookNames: [] };

  // First, parse BookNames.xml for localized book names
  const bookNamesData = parseBookNames(sourceDir, source);
  data.bookNames = bookNamesData;

  // Find and parse USFX files
  const files = fs.readdirSync(sourceDir).filter(f =>
    f.endsWith('_usfx.xml') || f.endsWith('usfx.xml') ||
    (f.endsWith('.xml') && f.includes('usfx'))
  );

  console.log(`    🔍 Found ${files.length} USFX files: ${files.join(', ')}`);

  if (files.length === 0) {
    console.warn(`    ⚠️ No USFX files found in ${sourceDir}`);
    const allFiles = fs.readdirSync(sourceDir);
    console.warn(`    📂 Available files: ${allFiles.join(', ')}`);
  }

  let bookCount = 0;
  let totalBooks = 0;

  for (const file of files) {
    console.log(`    📁 Processing file: ${file}`);
    const content = fs.readFileSync(path.join(sourceDir, file), 'utf8');
    const $ = cheerio.load(content, { xmlMode: true });

    // Count total books first
    if (totalBooks === 0) {
      totalBooks = $('book').length;
      console.log(`    📚 Found ${totalBooks} books in ${file}`);
    }

    $('book').each((_, bookEl) => {
      // Try 'id' first, then fall back to 'code' attribute
      const bookId = $(bookEl).attr('id') || $(bookEl).attr('code');

      if (!bookId) {
        console.warn(`    ⚠️ Book element without id/code attribute found`);
        return;
      }

      console.log(`    📖 Processing book with id: ${bookId}`);

      const bookCode = normalizeBookCode(bookId);
      if (!bookCode) {
        console.warn(`    ❌ Failed to normalize book code: ${bookId}`);
        return;
      }

      console.log(`    ✅ Normalized ${bookId} -> ${bookCode}`);

      bookCount++;
      if (bookCount % 10 === 0 || bookCount === totalBooks) {
        console.log(`    📖 Processing books (${bookCount}/${totalBooks})`);
      }

      // Get book abbreviation from BookNames.xml or use default
      const abbreviationData = bookNamesData.find(bn => bn.book_code === bookCode);
      const abbreviation = abbreviationData ? abbreviationData.abbreviation : bookCode;

      data.books.set(bookCode, {
        code: bookCode,
        name: getBookName(bookCode),
        testament: getTestament(bookCode),
        version_id: source.abbreviation
      });

      // Parse verses using milestone-based approach within paragraphs
      const { verses: parsedVerses, footnotes: parsedFootnotes } =
        parseBookMilestones($(bookEl), bookCode, source.abbreviation, $);

      console.log(`    📊 ${bookCode}: ${parsedVerses.length} verses, ${parsedFootnotes.length} footnotes`);

      if (parsedVerses.length === 0) {
        console.warn(`    ⚠️ No verses extracted from ${bookCode}`);
      }

      // Store parsed verses and footnotes
      data.verses.push(...parsedVerses);
      data.footnotes.push(...parsedFootnotes);

      // Track verses per chapter
      const chapterVerses = new Map();
      parsedVerses.forEach(verse => {
        const chapterKey = `${verse.book_code}_${verse.chapter}`;
        if (!chapterVerses.has(chapterKey)) {
          chapterVerses.set(chapterKey, []);
        }
        chapterVerses.get(chapterKey).push(verse.verse);
      });

      // Create chapter entries
      for (const [chapterKey, verseNums] of chapterVerses) {
        const [, chapterNumStr] = chapterKey.split('_');
        const chapterNum = parseInt(chapterNumStr);

        const chapterMapKey = `${chapterKey}_${source.abbreviation}`;
        data.chapters.set(chapterMapKey, {
          book_code: bookCode,
          chapter_number: chapterNum,
          verse_count: Math.max(...verseNums),
          version_id: source.abbreviation
        });
      }
    });
  }

  return data;
}

/**
 * Parse book content using milestone-based approach for USFX
 *
 * @param {Object} $book - Cheerio wrapped book element
 * @param {string} bookCode - Normalized book code (e.g., "GEN")
 * @param {string} versionId - Version abbreviation (e.g., "KJV")
 * @param {Object} $ - Cheerio instance for XML parsing
 * @returns {Object} {verses: VerseData[], footnotes: FootnoteData[]}
 */
function parseBookMilestones($book, bookCode, versionId, $) {
  const verses = [];
  const footnotes = [];

  // Process each content container that might contain verses
  $book.find('p').each((_, container) => {
    const $container = $(container);
    const vElements = $container.find('v');

    if (vElements.length === 0) return;

    // Parse content within this container using milestone boundaries
    const { parsedVerses, parsedFootnotes } =
      processMilestoneContent($container, bookCode, versionId, $);

    verses.push(...parsedVerses);
    footnotes.push(...parsedFootnotes);
  });

  return { verses, footnotes };
}

/**
 * Process content within a container using verse milestones
 *
 * @param {Object} $container - Cheerio wrapped container element (p, q, d, mt, s)
 * @param {string} bookCode - Normalized book code
 * @param {string} versionId - Version abbreviation
 * @param {Object} $ - Cheerio instance
 * @returns {Object} {parsedVerses: VerseData[], parsedFootnotes: FootnoteData[]}
 */
function processMilestoneContent($container, bookCode, versionId, $) {
  const verses = [];
  const footnotes = [];
  const childNodes = $container[0].childNodes;

  let currentVerse = null;
  let currentText = '';
  let currentFootnotes = [];

  for (const node of childNodes) {
    if (node.nodeType === 1) {
      const $element = $(node);

      if (node.tagName === 'v') {
        // Verse marker found - save previous verse if exists
        if (currentVerse && currentText.trim()) {
          verses.push({
            book_code: currentVerse.book_code,
            chapter: currentVerse.chapter,
            verse: currentVerse.verse,
            text: cleanVerseText(currentText),
            version_id: versionId
          });

          // Add footnotes for this verse
          currentFootnotes.forEach(footnote => {
            footnotes.push({
              book_code: currentVerse.book_code,
              chapter: currentVerse.chapter,
              verse: currentVerse.verse,
              version_id: versionId,
              type: footnote.type,
              caller: footnote.caller,
              content: footnote.content
            });
          });
        }

        // Start new verse - handle both 'bcv' and 'id' + 'bcv' attributes
        const bcv = $element.attr('bcv') || $element.attr('id');
        if (bcv) {
          const bcvParts = bcv.split('.');
          if (bcvParts.length === 3) {
            const [, chapterStr, verseStr] = bcvParts;
            const chapterNum = parseInt(chapterStr);
            const verseNum = parseInt(verseStr);

            if (!isNaN(chapterNum) && !isNaN(verseNum)) {
              currentVerse = {
                book_code: bookCode,
                chapter: chapterNum,
                verse: verseNum
              };
              currentText = '';
              currentFootnotes = [];
            }
          }
        }
      } else if (node.tagName === 've') {
        // Verse end marker - save current verse if exists
        if (currentVerse && currentText.trim()) {
          verses.push({
            book_code: currentVerse.book_code,
            chapter: currentVerse.chapter,
            verse: currentVerse.verse,
            text: cleanVerseText(currentText),
            version_id: versionId
          });

          // Add footnotes for this verse
          currentFootnotes.forEach(footnote => {
            footnotes.push({
              book_code: currentVerse.book_code,
              chapter: currentVerse.chapter,
              verse: currentVerse.verse,
              version_id: versionId,
              type: footnote.type,
              caller: footnote.caller,
              content: footnote.content
            });
          });

          // Reset for next verse
          currentVerse = null;
          currentText = '';
          currentFootnotes = [];
        }
      } else if (currentVerse) {
        // Process content within verse boundaries
        if (node.tagName === 'f') {
          // Footnote
          const footnote = extractFootnote($element, $);
          if (footnote) {
            currentFootnotes.push(footnote);
          }
        } else if (node.tagName === 'x') {
          // Cross-reference
          const crossRef = extractCrossReference($element, $);
          if (crossRef) {
            currentFootnotes.push(crossRef);
          }
        } else if (node.tagName === 'w') {
          // Word with attributes (Strong's, morphology, etc.)
          currentText += $element.text();
          // TODO: Extract word-level data for future enhancement
        } else if (['nd', 'wj', 'pn', 'k', 'add', 'qt', 'tl'].includes(node.tagName)) {
          // Theological markup - preserve text content
          currentText += $element.text();
        } else {
          // Other elements - include text content
          currentText += $element.text();
        }
      }
    } else if (node.nodeType === 3 && currentVerse) {
      // Text node within verse boundaries
      currentText += node.nodeValue;
    }
  }

  return { parsedVerses: verses, parsedFootnotes: footnotes };
}

/**
 * Parse BookNames.xml to get localized book names
 *
 * @param {string} sourceDir - Directory containing BookNames.xml
 * @param {Object} source - Source configuration object
 * @returns {BookNameData[]} Array of localized book name objects
 */
function parseBookNames(sourceDir, source) {
  const bookNames = [];
  const bookNamesPath = path.join(sourceDir, 'BookNames.xml');

  if (fs.existsSync(bookNamesPath)) {
    try {
      const content = fs.readFileSync(bookNamesPath, 'utf8');
      const $ = cheerio.load(content, { xmlMode: true });

      $('book').each((_, bookEl) => {
        const $book = $(bookEl);
        const code = $book.attr('code');
        const abbr = $book.attr('abbr');
        const short = $book.attr('short');
        const long = $book.attr('long');
        const alt = $book.attr('alt');

        if (code) {
          const normalizedCode = normalizeBookCode(code);
          if (normalizedCode) {
            bookNames.push({
              book_code: normalizedCode,
              language: source.language || 'unknown',
              abbreviation: abbr || code,
              short_name: short || code,
              long_name: long || short || code,
              alt_name: alt || null
            });
          }
        }
      });
    } catch (error) {
      console.warn(`    ⚠️ Could not parse BookNames.xml: ${error.message}`);
    }
  }

  return bookNames;
}

/**
 * Extract footnote content from USFX footnote element with sub-structure
 *
 * @param {Object} $footnote - Cheerio wrapped footnote element
 * @param {Object} $ - Cheerio instance
 * @returns {Object|null} {type: "footnote", caller: string, content: string} or null
 */
function extractFootnote($footnote, $) {
  const caller = $footnote.attr('caller') || '';

  // Extract structured footnote content
  const fr = $footnote.find('fr').text().trim(); // Reference
  const ft = $footnote.find('ft').text().trim(); // Main text
  const fk = $footnote.find('fk').text().trim(); // Keywords
  const fq = $footnote.find('fq').text().trim(); // Quotations

  // Combine content or use simple text if no structure
  let content = '';
  if (fr || ft || fk || fq) {
    const parts = [];
    if (fr) parts.push(fr);
    if (ft) parts.push(ft);
    if (fk) parts.push(fk);
    if (fq) parts.push(fq);
    content = parts.join(' ');
  } else {
    content = $footnote.text().trim();
  }

  if (content) {
    return {
      type: 'footnote',
      caller: caller,
      content: content
    };
  }

  return null;
}

/**
 * Extract cross-reference content from USFX cross-reference element with sub-structure
 *
 * @param {Object} $crossRef - Cheerio wrapped cross-reference element
 * @param {Object} $ - Cheerio instance
 * @returns {Object|null} {type: "cross_reference", caller: string, content: string} or null
 */
function extractCrossReference($crossRef, $) {
  const caller = $crossRef.attr('caller') || '';

  // Extract structured cross-reference content
  const xo = $crossRef.find('xo').text().trim(); // Origin
  const xt = $crossRef.find('xt').text().trim(); // Targets
  const xk = $crossRef.find('xk').text().trim(); // Keywords
  const xq = $crossRef.find('xq').text().trim(); // Quotations

  // Combine content or use simple text if no structure
  let content = '';
  if (xo || xt || xk || xq) {
    const parts = [];
    if (xo) parts.push(xo);
    if (xt) parts.push(xt);
    if (xk) parts.push(xk);
    if (xq) parts.push(xq);
    content = parts.join(' ');
  } else {
    content = $crossRef.text().trim();
  }

  if (content) {
    return {
      type: 'cross_reference',
      caller: caller,
      content: content
    };
  }

  return null;
}

module.exports = { parseUSFX };
