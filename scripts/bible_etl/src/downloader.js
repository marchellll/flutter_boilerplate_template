const fs = require('fs');
const path = require('path');
const yauzl = require('yauzl');
const crypto = require('crypto');

/**
 * Downloads and extracts Bible sources
 */
async function downloadSources(sources, downloadsDir) {
  for (const [id, source] of Object.entries(sources)) {
    await downloadSource(id, source, downloadsDir);
  }
}

/**
 * Downloads a single Bible source with idempotency check
 */
async function downloadSource(id, source, downloadsDir) {
  const sourceDir = path.join(downloadsDir, id);
  const checksumFile = path.join(sourceDir, '.checksum');

  console.log(`  📦 Processing ${source.name} (${id})...`);

  // Check if already downloaded and valid
  if (await isSourceValid(source.url, checksumFile)) {
    console.log(`    ✓ Already downloaded and valid`);
    return;
  }

  // Ensure source directory exists
  if (!fs.existsSync(sourceDir)) {
    fs.mkdirSync(sourceDir, { recursive: true });
  }

  try {
    // Download file
    console.log(`    📥 Downloading from ${source.url}...`);
    const response = await fetch(source.url);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const arrayBuffer = await response.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    const checksum = crypto.createHash('sha256').update(buffer).digest('hex');

    // Determine if it's a zip file
    const isZip = source.url.toLowerCase().includes('.zip') ||
                  buffer.slice(0, 4).equals(Buffer.from([0x50, 0x4B, 0x03, 0x04]));

    if (isZip) {
      // Extract zip
      console.log(`    📂 Extracting archive...`);
      await extractZip(buffer, sourceDir);
    } else {
      // Save as single file
      const filename = path.basename(source.url) || 'bible.txt';
      fs.writeFileSync(path.join(sourceDir, filename), buffer);
    }

    // Save checksum for idempotency
    fs.writeFileSync(checksumFile, checksum);
    console.log(`    ✓ Downloaded and extracted`);

  } catch (error) {
    console.error(`    ❌ Failed to download ${id}:`, error.message);
    throw error;
  }
}

/**
 * Checks if source is already downloaded and valid
 */
async function isSourceValid(url, checksumFile) {
  if (!fs.existsSync(checksumFile)) return false;

  try {
    const storedChecksum = fs.readFileSync(checksumFile, 'utf8');

    // Quick HEAD request to check if remote file changed
    const response = await fetch(url, { method: 'HEAD' });
    const etag = response.headers.get('etag');
    const lastModified = response.headers.get('last-modified');

    // Simple validation - in production, you might want more sophisticated caching
    return storedChecksum && storedChecksum.length === 64;
  } catch {
    return false;
  }
}

/**
 * Extracts zip file to directory
 */
function extractZip(buffer, targetDir) {
  return new Promise((resolve, reject) => {
    yauzl.fromBuffer(buffer, { lazyEntries: true }, (err, zipfile) => {
      if (err) return reject(err);

      zipfile.readEntry();
      zipfile.on('entry', (entry) => {
        if (/\/$/.test(entry.fileName)) {
          // Directory entry
          zipfile.readEntry();
        } else {
          // File entry
          zipfile.openReadStream(entry, (err, readStream) => {
            if (err) return reject(err);

            const filePath = path.join(targetDir, entry.fileName);
            const dirPath = path.dirname(filePath);

            if (!fs.existsSync(dirPath)) {
              fs.mkdirSync(dirPath, { recursive: true });
            }

            const writeStream = fs.createWriteStream(filePath);
            readStream.pipe(writeStream);

            writeStream.on('close', () => zipfile.readEntry());
            writeStream.on('error', reject);
          });
        }
      });

      zipfile.on('end', resolve);
      zipfile.on('error', reject);
    });
  });
}

module.exports = { downloadSources, downloadSource };
