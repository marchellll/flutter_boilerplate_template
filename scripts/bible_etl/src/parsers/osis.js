const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const { normalizeBookCode, getBookName, getTestament, cleanVerseText } = require('./utils');

/**
 * Parses OSIS format files
 */
function parseOSIS(sourceDir, source) {
  const data = { books: new Map(), chapters: new Map(), verses: [] };
  const files = fs.readdirSync(sourceDir).filter(f => f.endsWith('.osis') || f.endsWith('.xml'));

  for (const file of files) {
    const content = fs.readFileSync(path.join(sourceDir, file), 'utf8');
    const $ = cheerio.load(content, { xmlMode: true });

    $('div[type="book"]').each((_, bookEl) => {
      const osisId = $(bookEl).attr('osisID');
      const bookCode = normalizeBookCode(osisId);

      data.books.set(bookCode, {
        code: bookCode,
        name: getBookName(bookCode),
        testament: getTestament(bookCode)
      });

      $(bookEl).find('chapter').each((_, chapterEl) => {
        const chapterRef = $(chapterEl).attr('osisID');
        const chapterNum = parseInt(chapterRef.split('.')[1]);
        const chapterKey = `${bookCode}_${chapterNum}`;

        data.chapters.set(chapterKey, {
          book_code: bookCode,
          chapter_number: chapterNum,
          verse_count: 0
        });

        $(chapterEl).find('verse').each((_, verseEl) => {
          const verseRef = $(verseEl).attr('osisID');
          const verseNum = parseInt(verseRef.split('.')[2]);
          const verseText = cleanVerseText($(verseEl).text());

          if (verseText.trim()) {
            data.verses.push({
              book_code: bookCode,
              chapter: chapterNum,
              verse: verseNum,
              text: verseText.trim(),
              version_id: source.abbreviation
            });

            const chapter = data.chapters.get(chapterKey);
            if (chapter) {
              chapter.verse_count = Math.max(chapter.verse_count, verseNum);
            }
          }
        });
      });
    });
  }

  return data;
}

module.exports = { parseOSIS };
