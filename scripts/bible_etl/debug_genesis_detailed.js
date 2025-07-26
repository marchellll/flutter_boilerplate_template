const Database = require('better-sqlite3');

const db = new Database('dist/bible.db', { readonly: true });

console.log('🔍 Detailed verse analysis for Genesis 1...');

// Get all verses for Genesis 1 grouped by version
const kjvVerses = db.prepare(`
  SELECT v.verse_number, v.text
  FROM verses v
  JOIN books b ON v.book_id = b.id
  WHERE b.abbreviation = 'GEN' AND v.chapter_number = 1 AND v.version_id = 'KJV'
  ORDER BY v.verse_number
`).all();

const tsiVerses = db.prepare(`
  SELECT v.verse_number, v.text
  FROM verses v
  JOIN books b ON v.book_id = b.id
  WHERE b.abbreviation = 'GEN' AND v.chapter_number = 1 AND v.version_id = 'TSI'
  ORDER BY v.verse_number
`).all();

console.log(`📖 KJV Genesis 1: ${kjvVerses.length} verses`);
console.log(`📖 TSI Genesis 1: ${tsiVerses.length} verses`);

// Find verse numbers that exist in both
const kjvVerseNumbers = new Set(kjvVerses.map(v => v.verse_number));
const tsiVerseNumbers = new Set(tsiVerses.map(v => v.verse_number));

const bothHave = [...kjvVerseNumbers].filter(n => tsiVerseNumbers.has(n));
const kjvOnly = [...kjvVerseNumbers].filter(n => !tsiVerseNumbers.has(n));
const tsiOnly = [...tsiVerseNumbers].filter(n => !kjvVerseNumbers.has(n));

console.log('\n📊 Verse distribution:');
console.log(`Both versions have: ${bothHave.length} verses (${bothHave.slice(0, 10).join(', ')}...)`);
console.log(`KJV only: ${kjvOnly.length} verses (${kjvOnly.join(', ')})`);
console.log(`TSI only: ${tsiOnly.length} verses (${tsiOnly.join(', ')})`);

// Check highest verse numbers
const maxKjv = Math.max(...kjvVerseNumbers);
const maxTsi = Math.max(...tsiVerseNumbers);
console.log(`\n📏 Max verse numbers: KJV=${maxKjv}, TSI=${maxTsi}`);

// Sample verses to check content
console.log('\n📝 Sample KJV verses:');
kjvVerses.slice(0, 5).forEach(v => {
  console.log(`  ${v.verse_number}: "${v.text.substring(0, 60)}..."`);
});

console.log('\n📝 Sample TSI verses:');
tsiVerses.slice(0, 5).forEach(v => {
  console.log(`  ${v.verse_number}: "${v.text.substring(0, 60)}..."`);
});

db.close();
