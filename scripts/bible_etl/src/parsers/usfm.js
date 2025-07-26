const fs = require('fs');
const path = require('path');
const { normalizeBookCode, getBookName, getTestament, cleanVerseText } = require('./utils');

/**
 * Parses USFM format files
 */
function parseUSFM(sourceDir, source) {
  const data = { books: new Map(), chapters: new Map(), verses: [] };
  const files = fs.readdirSync(sourceDir).filter(f => f.endsWith('.usfm') || f.endsWith('.sfm'));

  for (const file of files) {
    const content = fs.readFileSync(path.join(sourceDir, file), 'utf8');
    const lines = content.split('\n');

    let currentBook = null;
    let currentChapter = null;
    let verseNumber = null;

    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed) continue;

      // Book marker
      if (trimmed.startsWith('\\id ')) {
        const bookCode = trimmed.substring(4).split(' ')[0];
        currentBook = normalizeBookCode(bookCode);
        if (!data.books.has(currentBook)) {
          data.books.set(currentBook, {
            code: currentBook,
            name: getBookName(currentBook),
            testament: getTestament(currentBook)
          });
        }
      }

      // Chapter marker
      else if (trimmed.startsWith('\\c ')) {
        currentChapter = parseInt(trimmed.substring(3));
        const chapterKey = `${currentBook}_${currentChapter}`;
        if (!data.chapters.has(chapterKey)) {
          data.chapters.set(chapterKey, {
            book_code: currentBook,
            chapter_number: currentChapter,
            verse_count: 0
          });
        }
        verseNumber = 0;
      }

      // Verse marker and content
      else if (trimmed.startsWith('\\v ')) {
        const verseMatch = trimmed.match(/\\v (\d+)(.*)$/);
        if (verseMatch && currentBook && currentChapter) {
          verseNumber = parseInt(verseMatch[1]);
          const verseText = cleanVerseText(verseMatch[2]);

          if (verseText.trim()) {
            data.verses.push({
              book_code: currentBook,
              chapter: currentChapter,
              verse: verseNumber,
              text: verseText.trim(),
              version_id: source.abbreviation
            });

            // Update verse count
            const chapterKey = `${currentBook}_${currentChapter}`;
            const chapter = data.chapters.get(chapterKey);
            if (chapter) {
              chapter.verse_count = Math.max(chapter.verse_count, verseNumber);
            }
          }
        }
      }
    }
  }

  return data;
}

module.exports = { parseUSFM };
