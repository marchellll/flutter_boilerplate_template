const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const { normalizeBookCode, getBookName, getTestament, cleanVerseText } = require('./utils');

/**
 * Parses USFX format files
 */
function parseUSFX(sourceDir, source) {
  const data = { books: new Map(), chapters: new Map(), verses: [] };
  const files = fs.readdirSync(sourceDir).filter(f => f.endsWith('.usfx') || f.endsWith('.xml'));

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
        console.log(`    � Processing books (${bookCount}/${totalBooks})`);
      }

      data.books.set(bookCode, {
        code: bookCode,
        name: getBookName(bookCode),
        testament: getTestament(bookCode)
      });

      // Find all verses in this book and group them by chapter
      const verses = $(bookEl).find('v');
      const chapterVerses = new Map();

      verses.each((_, verseEl) => {
        const $verse = $(verseEl);
        const verseNum = parseInt($verse.attr('id'));
        
        // Find the preceding chapter element
        let chapterNum = 1; // Default to chapter 1
        const precedingC = $verse.prevAll('c').first();
        if (precedingC.length > 0) {
          chapterNum = parseInt(precedingC.attr('id')) || 1;
        } else {
          // Look for chapter elements before this verse's parent
          let current = $verse.parent();
          while (current.length > 0 && current[0] !== bookEl) {
            const prevC = current.prevAll('c').first();
            if (prevC.length > 0) {
              chapterNum = parseInt(prevC.attr('id')) || 1;
              break;
            }
            current = current.parent();
          }
        }

        // Get verse text - find the next <ve> element and get all text between <v> and <ve>
        const $verseEnd = $verse.nextAll('ve').first();
        let verseText = '';
        
        if ($verseEnd.length > 0) {
          // Get all siblings between <v> and <ve>
          let current = $verse.next();
          while (current.length > 0 && !current.is('ve')) {
            if (current.get(0).nodeType === 3) { // Text node
              verseText += current.get(0).textContent;
            } else {
              verseText += current.text() + ' ';
            }
            current = current.next();
          }
        } else {
          // If no <ve> found, get text until next verse or end of parent
          let current = $verse.next();
          while (current.length > 0 && !current.is('v')) {
            if (current.get(0).nodeType === 3) { // Text node
              verseText += current.get(0).textContent;
            } else {
              verseText += current.text() + ' ';
            }
            current = current.next();
          }
        }

        verseText = cleanVerseText(verseText);

        if (verseText.trim()) {
          // Store verse data
          data.verses.push({
            book_code: bookCode,
            chapter: chapterNum,
            verse: verseNum,
            text: verseText.trim(),
            version_id: source.abbreviation
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

module.exports = { parseUSFX };
