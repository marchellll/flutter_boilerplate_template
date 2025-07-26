const fs = require('fs');
const cheerio = require('cheerio');

// Test parsing of Genesis 1 from TSI
const content = fs.readFileSync('/Users/marchell/playground/another_bible/scripts/bible_etl/downloads/tsi/ind_usfx.xml', 'utf8');
const $ = cheerio.load(content, { xmlMode: true });

console.log('🔍 Testing verse extraction from TSI Genesis 1...\n');

// Find the Genesis book
const genesisBook = $('book[id="GEN"]');
console.log(`Found Genesis book: ${genesisBook.length > 0 ? 'YES' : 'NO'}`);

if (genesisBook.length > 0) {
  // Find all verses in Genesis
  const allVerses = genesisBook.find('v');
  console.log(`Total verses found in Genesis: ${allVerses.length}`);

  // Look specifically at Chapter 1
  console.log('\n📖 Genesis Chapter 1 verses:');

  allVerses.each((i, verseEl) => {
    const $verse = $(verseEl);
    const verseId = $verse.attr('id');
    const bcv = $verse.attr('bcv');

    // Check if this is chapter 1
    if (bcv && bcv.includes('GEN.1.')) {
      console.log(`\n--- Verse ${verseId} (${bcv}) ---`);

      // Method 1: Get text until next <ve>
      const $verseEnd = $verse.nextAll('ve').first();
      let text1 = '';
      if ($verseEnd.length > 0) {
        let current = $verse.next();
        while (current.length > 0 && !current.is('ve')) {
          text1 += current.text() + ' ';
          current = current.next();
        }
      }

      // Method 2: Get text from parent until next verse
      let text2 = '';
      let current = $verse.next();
      while (current.length > 0 && !current.is('v') && !current.is('ve')) {
        text2 += current.text() + ' ';
        current = current.next();
      }

      // Method 3: Use bcv to parse chapter/verse info
      const bcvParts = bcv.split('.');
      const book = bcvParts[0];
      const chapter = parseInt(bcvParts[1]);
      const verse = parseInt(bcvParts[2]);

      console.log(`  BCV parsed: ${book} ${chapter}:${verse}`);
      console.log(`  Method 1 text: "${text1.trim().substring(0, 80)}..."`);
      console.log(`  Method 2 text: "${text2.trim().substring(0, 80)}..."`);

      if (i >= 10) return false; // Limit output
    }
  });
}
