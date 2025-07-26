const fs = require('fs');
const cheerio = require('cheerio');

// Check actual XML structure
const usfxFile = '/Users/marchell/playground/another_bible/scripts/bible_etl/downloads/kjv/eng-kjv2006_usfx.xml';
const content = fs.readFileSync(usfxFile, 'utf8');

// Look at first 5000 characters to see actual structure
console.log('📄 Raw XML structure (first 5000 chars):');
console.log(content.substring(0, 5000));
console.log('\n...\n');

// Look for verse patterns in raw XML
const verseMatches = content.match(/<ve\s[^>]*bcv="[^"]*"[^>]*>/g) || [];
console.log('🔍 Found verse patterns with "ve" tag:', verseMatches.slice(0, 5));

const $ = cheerio.load(content, { xmlMode: true });

// Check both 've' and 'v' elements
console.log('\n📊 Element counts:');
console.log('  - ve elements:', $('ve').length);
console.log('  - v elements:', $('v').length);

// Test the first book with 've' selector
const firstBook = $('book').first();
const vesWithBcv = firstBook.find('ve[bcv]');
console.log('\n📖 First book with "ve" selector:');
console.log('  - Book ID:', firstBook.attr('id'));
console.log('  - Verses (ve[bcv]):', vesWithBcv.length);

if (vesWithBcv.length > 0) {
  const firstVe = vesWithBcv.first();
  console.log('  - First verse bcv:', firstVe.attr('bcv'));
  console.log('  - First verse text:', firstVe.text().substring(0, 100));
}
