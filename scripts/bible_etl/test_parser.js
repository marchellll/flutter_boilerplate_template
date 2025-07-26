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

console.log('🧪 Testing USFX parser...');

try {
  const result = parseUSFX('./downloads/kjv', sources.kjv);
  
  console.log(`📚 Books parsed: ${result.books.size}`);
  console.log(`📄 Chapters parsed: ${result.chapters.size}`);
  console.log(`📝 Verses parsed: ${result.verses.length}`);
  
  if (result.verses.length > 0) {
    console.log(`📖 First verse: ${result.verses[0].text.substring(0, 100)}...`);
    console.log(`📖 Last verse: ${result.verses[result.verses.length - 1].text.substring(0, 100)}...`);
  }
  
  // Find a few sample verses
  const genesis1_1 = result.verses.find(v => v.book_code === 'GEN' && v.chapter === 1 && v.verse === 1);
  if (genesis1_1) {
    console.log(`🎯 Genesis 1:1: ${genesis1_1.text}`);
  } else {
    console.log('❌ Genesis 1:1 not found');
  }
  
} catch (error) {
  console.error('❌ Parser test failed:', error);
}
