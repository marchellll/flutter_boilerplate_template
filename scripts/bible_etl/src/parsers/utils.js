/**
 * Utility functions for Bible parsers
 */

function normalizeBookCode(code) {
  if (!code || typeof code !== 'string') {
    console.warn(`    ⚠️  Invalid book code: ${code}`);
    return 'UNKNOWN';
  }

  const mapping = {
    'GEN': 'GEN', 'EXO': 'EXO', 'LEV': 'LEV', 'NUM': 'NUM', 'DEU': 'DEU',
    'JOS': 'JOS', 'JDG': 'JDG', 'RUT': 'RUT', '1SA': '1SA', '2SA': '2SA',
    'MAT': 'MAT', 'MRK': 'MRK', 'LUK': 'LUK', 'JHN': 'JHN', 'ACT': 'ACT'
    // Add more mappings as needed
  };
  return mapping[code.toUpperCase()] || code.toUpperCase();
}

function getBookName(code) {
  const names = {
    'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numbers', 'DEU': 'Deuteronomy',
    'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John', 'ACT': 'Acts'
    // Add more names as needed
  };
  return names[code] || code;
}

function getTestament(code) {
  const oldTestament = ['GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA'];
  return oldTestament.includes(code) ? 'OLD' : 'NEW';
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
