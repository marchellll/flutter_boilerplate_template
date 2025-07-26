const fs = require('fs');
const cheerio = require('cheerio');

// Test actual USFX milestone structure
const usfxFile = '/Users/marchell/playground/another_bible/scripts/bible_etl/downloads/kjv/eng-kjv2006_usfx.xml';
const content = fs.readFileSync(usfxFile, 'utf8');
const $ = cheerio.load(content, { xmlMode: true });

console.log('🔍 USFX Milestone Structure Analysis');

// Get first book to understand structure
const firstBook = $('book').first();
console.log('\n📖 First Book:', firstBook.attr('id'));

// Find first chapter
const firstChapter = firstBook.find('c').first();
console.log('📄 First Chapter:', firstChapter.attr('id'));

// Look at raw structure around first verse
const genContent = firstBook.html();
const firstVerseMatch = genContent.match(/<v[^>]*bcv="GEN\.1\.1"[^>]*>.*?<\/v>/s);
if (firstVerseMatch) {
  console.log('\n📝 First verse marker structure:');
  console.log(firstVerseMatch[0]);
}

// Look for text between verse markers
const verseSample = genContent.substring(
  genContent.indexOf('<v id="1" bcv="GEN.1.1">'),
  genContent.indexOf('<v id="2" bcv="GEN.1.2">') + 50
);
console.log('\n📄 Text between verse 1 and 2:');
console.log(verseSample);

// Test milestone parsing approach
const vElements = firstBook.find('v[bcv]');
console.log(`\n📊 Found ${vElements.length} verse markers in Genesis`);

// Test extracting text between milestones
if (vElements.length >= 2) {
  const firstV = vElements.eq(0);
  const secondV = vElements.eq(1);

  console.log('\n🧪 Testing milestone text extraction:');
  console.log('First verse bcv:', firstV.attr('bcv'));
  console.log('Second verse bcv:', secondV.attr('bcv'));

  // Get all siblings between first and second verse
  let textBetween = '';
  let current = firstV[0].nextSibling;

  while (current && current !== secondV[0]) {
    if (current.nodeType === 3) { // Text node
      textBetween += current.nodeValue;
    } else if (current.nodeType === 1) { // Element node
      textBetween += $(current).text();
    }
    current = current.nextSibling;
  }

  console.log('Text between milestones:', textBetween.trim());
}
