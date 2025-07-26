const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

// Test the actual USFX file structure
const usfxFile = '/Users/marchell/playground/another_bible/scripts/bible_etl/downloads/kjv/eng-kjv2006_usfx.xml';

console.log('🔍 Debugging USFX file structure...');

if (!fs.existsSync(usfxFile)) {
  console.error('❌ USFX file not found:', usfxFile);
  process.exit(1);
}

const content = fs.readFileSync(usfxFile, 'utf8');
const $ = cheerio.load(content, { xmlMode: true });

console.log('📊 USFX File Analysis:');
console.log('  - File size:', (content.length / 1024 / 1024).toFixed(2), 'MB');
console.log('  - Books found:', $('book').length);

// Check first book structure
const firstBook = $('book').first();
if (firstBook.length > 0) {
  console.log('\n📖 First book analysis:');
  console.log('  - Book attributes:', firstBook[0].attribs);
  console.log('  - Book ID/Code:', firstBook.attr('id') || firstBook.attr('code'));

  // Check for verses with different possible selectors
  const versesWithBcv = firstBook.find('v[bcv]');
  const versesWithN = firstBook.find('v[n]');
  const allVerses = firstBook.find('v');

  console.log('  - Verses with bcv attribute:', versesWithBcv.length);
  console.log('  - Verses with n attribute:', versesWithN.length);
  console.log('  - Total verses:', allVerses.length);

  // Check first verse structure
  if (allVerses.length > 0) {
    const firstVerse = allVerses.first();
    console.log('\n📝 First verse analysis:');
    console.log('  - Verse attributes:', firstVerse[0].attribs);
    console.log('  - Verse text sample:', firstVerse.text().substring(0, 100) + '...');
  }

  // Check chapters
  const chapters = firstBook.find('c');
  console.log('  - Chapters found:', chapters.length);

  if (chapters.length > 0) {
    const firstChapter = chapters.first();
    console.log('  - First chapter attributes:', firstChapter[0].attribs);
  }
}

// Check overall structure
console.log('\n🏗️ Overall XML structure:');
console.log('  - Root element:', $.root().children().first()[0].name);
console.log('  - Direct children of root:', $.root().children().map((i, el) => el.name).get());

// Look for different verse patterns
console.log('\n🔍 Searching for verses in different ways:');
console.log('  - v[bcv] selector:', $('v[bcv]').length);
console.log('  - v[n] selector:', $('v[n]').length);
console.log('  - v selector:', $('v').length);
console.log('  - ve selector:', $('ve').length);

// Sample some verses to see the structure
const sampleVerses = $('v').slice(0, 5);
console.log('\n📝 Sample verses:');
sampleVerses.each((i, verse) => {
  const $v = $(verse);
  console.log(`  ${i+1}. Attributes:`, verse.attribs);
  console.log(`     Text: ${$v.text().substring(0, 50)}...`);
});
