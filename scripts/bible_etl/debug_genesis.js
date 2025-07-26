const Database = require('better-sqlite3');

const db = new Database('dist/bible.db', { readonly: true });

console.log('🔍 Investigating Genesis 1 verses...');

const genesis1Verses = db.prepare(`
  SELECT v.verse_number, v.version_id, v.text
  FROM verses v
  JOIN books b ON v.book_id = b.id
  WHERE b.abbreviation = 'GEN' AND v.chapter_number = 1
  ORDER BY v.verse_number, v.version_id
`).all();

console.log(`📖 Total Genesis 1 verses: ${genesis1Verses.length}`);

// Group by verse number
const byVerse = {};
genesis1Verses.forEach(v => {
  if (!byVerse[v.verse_number]) byVerse[v.verse_number] = [];
  byVerse[v.verse_number].push(v);
});

console.log('\n📊 Verse breakdown:');
Object.keys(byVerse).sort((a, b) => parseInt(a) - parseInt(b)).slice(0, 10).forEach(verseNum => {
  const verses = byVerse[verseNum];
  console.log(`Verse ${verseNum}: ${verses.length} version(s)`);
  verses.forEach(v => {
    console.log(`  ${v.version_id}: "${v.text.substring(0, 50)}..."`);
  });
});

// Check for duplicates within same version
console.log('\n🔍 Checking for duplicates within same version:');
const duplicates = [];
const seen = new Set();

genesis1Verses.forEach(v => {
  const key = `${v.verse_number}_${v.version_id}`;
  if (seen.has(key)) {
    duplicates.push(v);
  } else {
    seen.add(key);
  }
});

if (duplicates.length > 0) {
  console.log(`❌ Found ${duplicates.length} duplicate verses!`);
  duplicates.forEach(d => {
    console.log(`  Verse ${d.verse_number} (${d.version_id}): "${d.text.substring(0, 50)}..."`);
  });
} else {
  console.log('✅ No duplicates found within same version');
}

db.close();
