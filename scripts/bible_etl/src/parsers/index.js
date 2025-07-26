const { parseUSFM } = require('./usfm');
const { parseUSFX } = require('./usfx');
const { parseUSX } = require('./usx');
const { parseOSIS } = require('./osis');
const { parseText } = require('./text');

module.exports = {
  parseUSFM,
  parseUSFX,
  parseUSX,
  parseOSIS,
  parseText
};
