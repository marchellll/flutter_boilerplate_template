const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const { normalizeBookCode, getBookName, getTestament, cleanVerseText } = require('./utils');

/**
 * Parses USX format files
 */
function parseUSX(sourceDir, source) {
  // Similar to USFX but with USX-specific XML structure
  const data = { books: new Map(), chapters: new Map(), verses: [] };
  const files = fs.readdirSync(sourceDir).filter(f => f.endsWith('.usx'));

  for (const file of files) {
    const content = fs.readFileSync(path.join(sourceDir, file), 'utf8');
    const $ = cheerio.load(content, { xmlMode: true });

    const bookCode = normalizeBookCode($('usx').attr('book'));

    data.books.set(bookCode, {
      code: bookCode,
      name: getBookName(bookCode),
      testament: getTestament(bookCode)
    });

    let currentChapter = null;

    $('para, chapter, verse').each((_, el) => {
      const tagName = el.tagName;

      if (tagName === 'chapter') {
        currentChapter = parseInt($(el).attr('number'));
        const chapterKey = `${bookCode}_${currentChapter}`;

        data.chapters.set(chapterKey, {
          book_code: bookCode,
          chapter_number: currentChapter,
          verse_count: 0
        });
      }

      else if (tagName === 'verse' && currentChapter) {
        const verseNum = parseInt($(el).attr('number'));
        const verseText = cleanVerseText($(el).text());

        if (verseText.trim()) {
          data.verses.push({
            book_code: bookCode,
            chapter: currentChapter,
            verse: verseNum,
            text: verseText.trim(),
            version_id: source.abbreviation
          });

          const chapterKey = `${bookCode}_${currentChapter}`;
          const chapter = data.chapters.get(chapterKey);
          if (chapter) {
            chapter.verse_count = Math.max(chapter.verse_count, verseNum);
          }
        }
      }
    });
  }

  return data;
}

module.exports = { parseUSX };
