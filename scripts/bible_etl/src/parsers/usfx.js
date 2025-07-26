const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const { normalizeBookCode, getBookName, getTestament, cleanVerseText } = require('./utils');

/**
 * Parses USFX format files
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

  let bookCount = 0;
  let totalBooks = 0;

  for (const file of files) {
    const content = fs.readFileSync(path.join(sourceDir, file), 'utf8');
    const $ = cheerio.load(content, { xmlMode: true });

    // Count total books first
    if (totalBooks === 0) {
      totalBooks = $('book').length;
    }

    $('book').each((_, bookEl) => {
      // Try 'id' first, then fall back to 'code' attribute
      const bookId = $(bookEl).attr('id') || $(bookEl).attr('code');

      if (!bookId) {
        return;
      }

      const bookCode = normalizeBookCode(bookId);
      if (!bookCode) {
        return;
      }

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

      // Parse all verses using bcv attribute for accurate parsing
      const verses = $(bookEl).find('v[bcv]');
      const chapterVerses = new Map();

      verses.each((_, verseEl) => {
        const $verse = $(verseEl);
        const bcv = $verse.attr('bcv');
        
        if (!bcv) return;

        // Parse BCV (Book.Chapter.Verse) format
        const bcvParts = bcv.split('.');
        if (bcvParts.length !== 3) return;

        const [bkvBook, chapterStr, verseStr] = bcvParts;
        const chapterNum = parseInt(chapterStr);
        const verseNum = parseInt(verseStr);

        if (isNaN(chapterNum) || isNaN(verseNum)) return;

        // Extract verse text and footnotes
        const { text, footnotes } = extractVerseContent($verse, $);
        
        if (text.trim()) {
          // Store verse data
          data.verses.push({
            book_code: bookCode,
            chapter: chapterNum,
            verse: verseNum,
            text: text.trim(),
            version_id: source.abbreviation
          });

          // Store footnotes
          footnotes.forEach(footnote => {
            data.footnotes.push({
              book_code: bookCode,
              chapter: chapterNum,
              verse: verseNum,
              version_id: source.abbreviation,
              type: footnote.type,
              caller: footnote.caller,
              content: footnote.content
            });
          });

          // Track verses per chapter
          const chapterKey = `${bookCode}_${chapterNum}`;
          if (!chapterVerses.has(chapterKey)) {
            chapterVerses.set(chapterKey, []);
          }
          chapterVerses.get(chapterKey).push(verseNum);
        }
      });

      // Create chapter entries
      for (const [chapterKey, verseNums] of chapterVerses) {
        const [, chapterNumStr] = chapterKey.split('_');
        const chapterNum = parseInt(chapterNumStr);
        
        data.chapters.set(chapterKey, {
          book_code: bookCode,
          chapter_number: chapterNum,
          verse_count: Math.max(...verseNums)
        });
      }
    });
  }

  return data;
}

/**
 * Parse BookNames.xml to get localized book names
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
 * Extract verse content and footnotes from USFX verse element
 */
function extractVerseContent($verse, $) {
  const footnotes = [];
  let verseText = '';
  
  // Find the closing </ve> tag
  const $verseEnd = $verse.nextAll('ve').first();
  
  if ($verseEnd.length > 0) {
    // Get all content between <v> and <ve>
    let current = $verse.next();
    
    while (current.length > 0 && !current.is('ve')) {
      if (current.get(0).nodeType === 3) {
        // Text node
        verseText += current.get(0).textContent;
      } else if (current.is('f')) {
        // Footnote element
        const footnote = extractFootnote(current, $);
        if (footnote) {
          footnotes.push(footnote);
        }
      } else if (current.is('x')) {
        // Cross-reference
        const crossRef = extractCrossReference(current, $);
        if (crossRef) {
          footnotes.push(crossRef);
        }
      } else {
        // Other elements - just get text content
        verseText += current.text() + ' ';
      }
      current = current.next();
    }
  } else {
    // Fallback: get text until next verse or end of parent
    let current = $verse.next();
    while (current.length > 0 && !current.is('v')) {
      if (current.get(0).nodeType === 3) {
        verseText += current.get(0).textContent;
      } else if (current.is('f')) {
        const footnote = extractFootnote(current, $);
        if (footnote) {
          footnotes.push(footnote);
        }
      } else if (current.is('x')) {
        const crossRef = extractCrossReference(current, $);
        if (crossRef) {
          footnotes.push(crossRef);
        }
      } else {
        verseText += current.text() + ' ';
      }
      current = current.next();
    }
  }
  
  return {
    text: cleanVerseText(verseText),
    footnotes: footnotes
  };
}

/**
 * Extract footnote content from USFX footnote element
 */
function extractFootnote($footnote, $) {
  const caller = $footnote.attr('caller') || '';
  const content = $footnote.text().trim();
  
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
 * Extract cross-reference content from USFX cross-reference element
 */
function extractCrossReference($crossRef, $) {
  const caller = $crossRef.attr('caller') || '';
  const content = $crossRef.text().trim();
  
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
