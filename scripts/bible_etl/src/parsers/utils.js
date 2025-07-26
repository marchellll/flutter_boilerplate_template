/**
 * Utility functions for Bible parsers
 */

function normalizeBookCode(code) {
  if (!code || typeof code !== 'string') {
    console.warn(`    ⚠️ Invalid book code: ${code}`);
    return null;
  }

  // Complete Bible book mapping (66 canonical books)
  const mapping = {
    // Old Testament (39 books)
    'GEN': 'GEN', 'EXO': 'EXO', 'LEV': 'LEV', 'NUM': 'NUM', 'DEU': 'DEU',
    'JOS': 'JOS', 'JDG': 'JDG', 'RUT': 'RUT', '1SA': '1SA', '2SA': '2SA',
    '1KI': '1KI', '2KI': '2KI', '1CH': '1CH', '2CH': '2CH', 'EZR': 'EZR',
    'NEH': 'NEH', 'EST': 'EST', 'JOB': 'JOB', 'PSA': 'PSA', 'PRO': 'PRO',
    'ECC': 'ECC', 'SNG': 'SNG', 'ISA': 'ISA', 'JER': 'JER', 'LAM': 'LAM',
    'EZK': 'EZK', 'DAN': 'DAN', 'HOS': 'HOS', 'JOL': 'JOL', 'AMO': 'AMO',
    'OBA': 'OBA', 'JON': 'JON', 'MIC': 'MIC', 'NAM': 'NAM', 'HAB': 'HAB',
    'ZEP': 'ZEP', 'HAG': 'HAG', 'ZEC': 'ZEC', 'MAL': 'MAL',

    // New Testament (27 books)
    'MAT': 'MAT', 'MRK': 'MRK', 'LUK': 'LUK', 'JHN': 'JHN', 'ACT': 'ACT',
    'ROM': 'ROM', '1CO': '1CO', '2CO': '2CO', 'GAL': 'GAL', 'EPH': 'EPH',
    'PHP': 'PHP', 'COL': 'COL', '1TH': '1TH', '2TH': '2TH', '1TI': '1TI',
    '2TI': '2TI', 'TIT': 'TIT', 'PHM': 'PHM', 'HEB': 'HEB', 'JAS': 'JAS',
    '1PE': '1PE', '2PE': '2PE', '1JN': '1JN', '2JN': '2JN', '3JN': '3JN',
    'JUD': 'JUD', 'REV': 'REV',

    // Common alternative codes
    'JOEL': 'JOL', 'SONG': 'SNG', 'SONGS': 'SNG', 'ECCLESIASTES': 'ECC',
    'EZEKIEL': 'EZK', 'HOSEA': 'HOS', 'AMOS': 'AMO', 'OBADIAH': 'OBA',
    'JONAH': 'JON', 'MICAH': 'MIC', 'NAHUM': 'NAM', 'HABAKKUK': 'HAB',
    'ZEPHANIAH': 'ZEP', 'HAGGAI': 'HAG', 'ZECHARIAH': 'ZEC', 'MALACHI': 'MAL',
    'MATTHEW': 'MAT', 'MARK': 'MRK', 'LUKE': 'LUK', 'JOHN': 'JHN', 'ACTS': 'ACT',
    'ROMANS': 'ROM', 'CORINTHIANS': '1CO', 'GALATIANS': 'GAL', 'EPHESIANS': 'EPH',
    'PHILIPPIANS': 'PHP', 'COLOSSIANS': 'COL', 'THESSALONIANS': '1TH',
    'TIMOTHY': '1TI', 'TITUS': 'TIT', 'PHILEMON': 'PHM', 'HEBREWS': 'HEB',
    'JAMES': 'JAS', 'PETER': '1PE', 'JUDE': 'JUD', 'REVELATION': 'REV'
  };

  const normalized = mapping[code.toUpperCase()];
  if (!normalized) {
    console.warn(`    ⚠️ Unknown book code: ${code} - this book will be skipped`);
    return null;
  }

  return normalized;
}

function getBookName(code) {
  const names = {
    // Old Testament
    'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numbers', 'DEU': 'Deuteronomy',
    'JOS': 'Joshua', 'JDG': 'Judges', 'RUT': 'Ruth', '1SA': '1 Samuel', '2SA': '2 Samuel',
    '1KI': '1 Kings', '2KI': '2 Kings', '1CH': '1 Chronicles', '2CH': '2 Chronicles',
    'EZR': 'Ezra', 'NEH': 'Nehemiah', 'EST': 'Esther', 'JOB': 'Job', 'PSA': 'Psalms',
    'PRO': 'Proverbs', 'ECC': 'Ecclesiastes', 'SNG': 'Song of Solomon', 'ISA': 'Isaiah',
    'JER': 'Jeremiah', 'LAM': 'Lamentations', 'EZK': 'Ezekiel', 'DAN': 'Daniel',
    'HOS': 'Hosea', 'JOL': 'Joel', 'AMO': 'Amos', 'OBA': 'Obadiah', 'JON': 'Jonah',
    'MIC': 'Micah', 'NAM': 'Nahum', 'HAB': 'Habakkuk', 'ZEP': 'Zephaniah', 'HAG': 'Haggai',
    'ZEC': 'Zechariah', 'MAL': 'Malachi',

    // New Testament
    'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John', 'ACT': 'Acts',
    'ROM': 'Romans', '1CO': '1 Corinthians', '2CO': '2 Corinthians', 'GAL': 'Galatians',
    'EPH': 'Ephesians', 'PHP': 'Philippians', 'COL': 'Colossians', '1TH': '1 Thessalonians',
    '2TH': '2 Thessalonians', '1TI': '1 Timothy', '2TI': '2 Timothy', 'TIT': 'Titus',
    'PHM': 'Philemon', 'HEB': 'Hebrews', 'JAS': 'James', '1PE': '1 Peter', '2PE': '2 Peter',
    '1JN': '1 John', '2JN': '2 John', '3JN': '3 John', 'JUD': 'Jude', 'REV': 'Revelation'
  };
  return names[code] || code;
}

function getTestament(code) {
  const oldTestament = [
    'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA',
    '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO',
    'ECC', 'SNG', 'ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO',
    'OBA', 'JON', 'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL'
  ];
  return oldTestament.includes(code) ? 'OT' : 'NT';
}

function cleanVerseText(text) {
  return text
    .replace(/\\[a-z]+\*?/g, '') // Remove USFM markers
    .replace(/\s+/g, ' ')        // Normalize whitespace
    .trim();
}

module.exports = {
  normalizeBookCode,
  getBookName,
  getTestament,
  cleanVerseText
};
