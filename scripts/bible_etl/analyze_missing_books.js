#!/usr/bin/env node

// All 66 canonical books
const canonical66 = [
  // Old Testament (39 books)
  'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA',
  '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO',
  'ECC', 'SNG', 'ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO',
  'OBA', 'JON', 'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL',
  // New Testament (27 books)
  'MAT', 'MRK', 'LUK', 'JHN', 'ACT', 'ROM', '1CO', '2CO', 'GAL', 'EPH',
  'PHP', 'COL', '1TH', '2TH', '1TI', '2TI', 'TIT', 'PHM', 'HEB', 'JAS',
  '1PE', '2PE', '1JN', '2JN', '3JN', 'JUD', 'REV'
];

// TSI books found (from the log output)
const tsiFound = [
  'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA',
  '1KI', '2KI', 'EZR', 'NEH', 'EST', 'PRO', 'ECC', 'ISA', 'JON', 'ZEC',
  'MAL', 'MAT', 'MRK', 'LUK', 'JHN', 'ACT', 'ROM', '1CO', '2CO', 'GAL',
  'EPH', 'PHP', 'COL', '1TH', '2TH', '1TI', '2TI', 'TIT', 'PHM', 'HEB',
  'JAS', '1PE', '2PE', '1JN', '2JN', '3JN', 'JUD', 'REV'
];

console.log('📚 CANONICAL BIBLE ANALYSIS');
console.log('═══════════════════════════════════════');
console.log(`Total canonical books: ${canonical66.length}`);
console.log(`TSI books found: ${tsiFound.length}`);
console.log(`Missing books: ${canonical66.length - tsiFound.length}`);
console.log();

// Find missing books
const missing = canonical66.filter(book => !tsiFound.includes(book));
console.log('❌ MISSING BOOKS FROM TSI:');
console.log('═══════════════════════════════════════');
missing.forEach((book, index) => {
  console.log(`${(index + 1).toString().padStart(2)}. ${book}`);
});
console.log();

// Categorize missing books
const oldTestament = ['GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA',
  '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO',
  'ECC', 'SNG', 'ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO',
  'OBA', 'JON', 'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL'];

const newTestament = ['MAT', 'MRK', 'LUK', 'JHN', 'ACT', 'ROM', '1CO', '2CO', 'GAL', 'EPH',
  'PHP', 'COL', '1TH', '2TH', '1TI', '2TI', 'TIT', 'PHM', 'HEB', 'JAS',
  '1PE', '2PE', '1JN', '2JN', '3JN', 'JUD', 'REV'];

const missingOT = missing.filter(book => oldTestament.includes(book));
const missingNT = missing.filter(book => newTestament.includes(book));

console.log('📖 MISSING BY TESTAMENT:');
console.log('═══════════════════════════════════════');
console.log(`Old Testament missing: ${missingOT.length}`);
missingOT.forEach(book => console.log(`  - ${book}`));
console.log();
console.log(`New Testament missing: ${missingNT.length}`);
missingNT.forEach(book => console.log(`  - ${book}`));
console.log();

// Book name mappings for clarity
const bookNames = {
  '1CH': '1 Chronicles', '2CH': '2 Chronicles', 'JOB': 'Job', 'PSA': 'Psalms',
  'SNG': 'Song of Songs', 'JER': 'Jeremiah', 'LAM': 'Lamentations',
  'EZK': 'Ezekiel', 'DAN': 'Daniel', 'HOS': 'Hosea', 'JOL': 'Joel',
  'AMO': 'Amos', 'OBA': 'Obadiah', 'MIC': 'Micah', 'NAM': 'Nahum',
  'HAB': 'Habakkuk', 'ZEP': 'Zephaniah', 'HAG': 'Haggai'
};

console.log('📝 MISSING BOOKS WITH FULL NAMES:');
console.log('═══════════════════════════════════════');
missing.forEach((book, index) => {
  const fullName = bookNames[book] || book;
  console.log(`${(index + 1).toString().padStart(2)}. ${book} - ${fullName}`);
});
