const { parseUSFX } = require('./src/parsers/usfx');
const sources = {
  "kjv": {
    "name": "King James Version",
    "format": "usfx",
    "url": "https://ebible.org/Scriptures/eng-kjv2006_usfx.zip",
    "language": "en",
    "abbreviation": "KJV",
    "description": "The King James Version (1769) is a classic English translation known for its literary beauty and historical significance."
  }
};

console.log('🧪 Testing for verse duplicates...');

try {
  const result = parseUSFX('./downloads/kjv', sources.kjv);
  
  console.log(`📚 Books parsed: ${result.books.size}`);
  console.log(`📄 Chapters parsed: ${result.chapters.size}`);
  console.log(`📝 Verses parsed: ${result.verses.length}`);
  
  // Check for duplicates
  const verseKeys = new Map();
  const duplicates = [];
  
  for (const verse of result.verses) {
    const key = `${verse.book_code}_${verse.chapter}_${verse.verse}_${verse.version_id}`;
    if (verseKeys.has(key)) {
      duplicates.push({
        key,
        original: verseKeys.get(key),
        duplicate: verse
      });
    } else {
      verseKeys.set(key, verse);
    }
  }
  
  console.log(`🔍 Found ${duplicates.length} duplicate verses`);
  
  if (duplicates.length > 0) {
    console.log('📋 First 5 duplicates:');
    duplicates.slice(0, 5).forEach(dup => {
      console.log(`  - ${dup.key}`);
      console.log(`    Original: "${dup.original.text.substring(0, 50)}..."`);
      console.log(`    Duplicate: "${dup.duplicate.text.substring(0, 50)}..."`);
    });
  }
  
  // Check Genesis 1 specifically
  const genesis1Verses = result.verses.filter(v => v.book_code === 'GEN' && v.chapter === 1);
  console.log(`📖 Genesis 1 has ${genesis1Verses.length} verses`);
  
  // Group by verse number to see duplicates
  const gen1ByVerse = {};
  genesis1Verses.forEach(v => {
    if (!gen1ByVerse[v.verse]) gen1ByVerse[v.verse] = [];
    gen1ByVerse[v.verse].push(v);
  });
  
  console.log('📊 Genesis 1 verse breakdown:');
  Object.keys(gen1ByVerse).sort((a, b) => parseInt(a) - parseInt(b)).slice(0, 10).forEach(verseNum => {
    const verses = gen1ByVerse[verseNum];
    console.log(`  Verse ${verseNum}: ${verses.length} occurrence(s)`);
    if (verses.length > 1) {
      verses.forEach((v, i) => {
        console.log(`    ${i + 1}: "${v.text.substring(0, 30)}..."`);
      });
    }
  });
  
} catch (error) {
  console.error('❌ Parser test failed:', error);
}
