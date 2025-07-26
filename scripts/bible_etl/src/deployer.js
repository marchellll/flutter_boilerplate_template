const fs = require('fs');
const path = require('path');

/**
 * Deploys database to Flutter assets directory
 */
async function deployAssets(dbPath) {
  const assetsDir = '../../assets/bibles';
  const targetPath = path.join(assetsDir, 'bible.db');

  // Ensure assets directory exists
  if (!fs.existsSync(assetsDir)) {
    fs.mkdirSync(assetsDir, { recursive: true });
  }

  // Copy database file
  fs.copyFileSync(dbPath, targetPath);

  // Update pubspec.yaml assets section (if needed)
  await updatePubspecAssets();

  console.log(`    📱 Database deployed to ${targetPath}`);

  // Generate database info file
  generateDatabaseInfo(dbPath, assetsDir);
}

/**
 * Updates pubspec.yaml to include assets
 */
async function updatePubspecAssets() {
  const pubspecPath = '../../pubspec.yaml';

  if (!fs.existsSync(pubspecPath)) {
    console.warn('    ⚠️ pubspec.yaml not found, skipping assets update');
    return;
  }

  let content = fs.readFileSync(pubspecPath, 'utf8');

  // Check if assets section already includes bibles
  if (content.includes('assets/bibles/')) {
    console.log('    ✓ pubspec.yaml assets already configured');
    return;
  }

  // Add assets section if it doesn't exist
  if (!content.includes('flutter:')) {
    content += '\nflutter:\n  assets:\n    - assets/bibles/\n';
  } else if (!content.includes('assets:')) {
    content = content.replace('flutter:', 'flutter:\n  assets:\n    - assets/bibles/');
  } else {
    content = content.replace('assets:', 'assets:\n    - assets/bibles/');
  }

  fs.writeFileSync(pubspecPath, content);
  console.log('    📝 Updated pubspec.yaml assets');
}

/**
 * Generates database information file
 */
function generateDatabaseInfo(dbPath, assetsDir) {
  const Database = require('better-sqlite3');
  const db = new Database(dbPath, { readonly: true });

  // Get database statistics
  const stats = {
    version: db.prepare('SELECT value FROM metadata WHERE key = ?').get('version')?.value,
    built_at: db.prepare('SELECT value FROM metadata WHERE key = ?').get('built_at')?.value,
    book_count: db.prepare('SELECT COUNT(*) as count FROM books').get().count,
    chapter_count: db.prepare('SELECT COUNT(*) as count FROM chapters').get().count,
    verse_count: db.prepare('SELECT COUNT(*) as count FROM verses').get().count,
    versions: db.prepare('SELECT value FROM metadata WHERE key = ?').get('versions')?.value?.split(',') || [],
    size_bytes: fs.statSync(dbPath).size
  };

  db.close();

  // Write info file
  const infoPath = path.join(assetsDir, 'database_info.json');
  fs.writeFileSync(infoPath, JSON.stringify(stats, null, 2));

  console.log('    📊 Generated database info file');
  console.log(`       - Books: ${stats.book_count}`);
  console.log(`       - Chapters: ${stats.chapter_count}`);
  console.log(`       - Verses: ${stats.verse_count}`);
  console.log(`       - Versions: ${stats.versions.join(', ')}`);
  console.log(`       - Size: ${(stats.size_bytes / 1024 / 1024).toFixed(2)} MB`);
}

module.exports = { deployAssets };
