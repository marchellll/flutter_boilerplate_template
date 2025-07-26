const { parseAllSources } = require('./src/parser');

const sources = {
  "kjv": {
    "name": "King James Version",
    "format": "usfx",
    "url": "https://ebible.org/Scriptures/eng-kjv2006_usfx.zip",
    "language": "en",
    "abbreviation": "KJV",
    "description": "The King James Version (1769) is a classic English translation known for its literary beauty and historical significance."
  },
  "tsi": {
    "name": "Terjemahan Sederhana Indonesia",
    "format": "usfx",
    "url": "https://ebible.org/Scriptures/ind_usfx.zip",
    "language": "id",
    "abbreviation": "TSI",
    "description": "Terjemahan Sederhana Indonesia - Simple Indonesian translation for easy understanding."
  }
};

console.log('🧪 Testing full parsing pipeline...');

parseAllSources(sources, './downloads').then(result => {
  console.log(`📚 Books parsed: ${result.books.size}`);
  console.log(`📄 Chapters parsed: ${result.chapters.size}`);
  console.log(`📝 Verses parsed: ${result.verses.length}`);

  // Check by version
  const byVersion = {};
  result.verses.forEach(v => {
    if (!byVersion[v.version_id]) byVersion[v.version_id] = 0;
    byVersion[v.version_id]++;
  });

  console.log('📊 Verses by version:');
  Object.entries(byVersion).forEach(([version, count]) => {
    console.log(`  ${version}: ${count} verses`);
  });

  // Check Genesis 1 specifically
  const genesis1Verses = result.verses.filter(v => v.book_code === 'GEN' && v.chapter === 1);
  console.log(`📖 Genesis 1 has ${genesis1Verses.length} verses total`);

  // Group by version
  const gen1ByVersion = {};
  genesis1Verses.forEach(v => {
    if (!gen1ByVersion[v.version_id]) gen1ByVersion[v.version_id] = [];
    gen1ByVersion[v.version_id].push(v);
  });

  console.log('📊 Genesis 1 by version:');
  Object.entries(gen1ByVersion).forEach(([version, verses]) => {
    console.log(`  ${version}: ${verses.length} verses`);
  });

}).catch(error => {
  console.error('❌ Pipeline test failed:', error);
});
