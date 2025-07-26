const { parseUSFX } = require('./usfx');

// Placeholder functions for formats not yet implemented
function parseUSFM() {
  throw new Error('USFM parser not implemented yet. Only USFX format is currently supported.');
}

function parseUSX() {
  throw new Error('USX parser not implemented yet. Only USFX format is currently supported.');
}

function parseOSIS() {
  throw new Error('OSIS parser not implemented yet. Only USFX format is currently supported.');
}

function parseText() {
  throw new Error('Text parser not implemented yet. Only USFX format is currently supported.');
}

module.exports = {
  parseUSFM,
  parseUSFX,
  parseUSX,
  parseOSIS,
  parseText
};
