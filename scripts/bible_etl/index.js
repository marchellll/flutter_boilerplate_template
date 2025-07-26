const fs = require('fs');
const path = require('path');
const { downloadSources } = require('./src/downloader');
const { parseAllSources } = require('./src/parser');
const { buildDatabase } = require('./src/database');
const { deployAssets } = require('./src/deployer');

const DOWNLOADS_DIR = './downloads';
const DIST_DIR = './dist';
const OUTPUT_DB = path.join(DIST_DIR, 'bible.db');
const SOURCES_CONFIG = './bible_sources.json';

async function main() {
  const args = process.argv.slice(2);
  const downloadOnly = args.includes('--download-only');
  const parseOnly = args.includes('--parse-only');
  const deployOnly = args.includes('--deploy-only');

  try {
    console.log('🚀 Starting Bible ETL Pipeline...');

    // Ensure directories exist
    if (!fs.existsSync(DOWNLOADS_DIR)) {
      fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });
    }
    if (!fs.existsSync(DIST_DIR)) {
      fs.mkdirSync(DIST_DIR, { recursive: true });
    }

    // Load sources configuration
    const sources = JSON.parse(fs.readFileSync(SOURCES_CONFIG, 'utf8'));

    if (!deployOnly) {
      // Step 1: Download sources
      if (!parseOnly) {
        console.log('📥 Downloading Bible sources...');
        await downloadSources(sources, DOWNLOADS_DIR);
      }

      // Step 2: Parse all sources
      if (!downloadOnly) {
        console.log('📖 Parsing Bible files...');
        const parsedData = await parseAllSources(sources, DOWNLOADS_DIR);

        // Step 3: Build SQLite database with source info
        console.log('🗄️ Building SQLite database...');
        await buildDatabase(parsedData, OUTPUT_DB, sources);
      }
    }

    // Step 4: Deploy to Flutter assets
    if (!downloadOnly && !parseOnly) {
      console.log('🚀 Deploying to Flutter assets...');
      await deployAssets(OUTPUT_DB);
    }

    console.log('✅ ETL Pipeline completed successfully!');

  } catch (error) {
    console.error('❌ ETL Pipeline failed:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { main };
if (require.main === module) {
  main();
}

module.exports = { main };
