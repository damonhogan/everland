const fs = require('fs')
const path = require('path')

// Simple scaffold: scans an input directory and writes a content index JSON
// Real cartoonization requires third-party tooling or ML models; this is a placeholder scaffold.

const inDir = process.argv[2] || path.join(__dirname, '..', 'public', 'images')
const out = path.join(__dirname, '..', 'public', 'bbs', 'content_index.json')

// If CARTOONIZE_API_URL is set, this script will POST file paths to that API as a scaffold.
const CARTOONIZE_API_URL = process.env.CARTOONIZE_API_URL || ''

function scan(dir) {
  const files = []
  const names = fs.readdirSync(dir)
  for (const n of names) {
    const p = path.join(dir, n)
    const st = fs.statSync(p)
    if (st.isDirectory()) files.push(...scan(p))
    else files.push({ name: n, path: path.relative(path.join(__dirname, '..', 'public'), p).replace(/\\/g, '/') })
  }
  return files
}

try {
  if (!fs.existsSync(inDir)) {
    console.error('Input directory not found:', inDir)
    process.exit(1)
  }
  const found = scan(inDir)
  const index = { generatedAt: Date.now(), images: found }
  fs.writeFileSync(out, JSON.stringify(index, null, 2))
  console.log('Wrote', out, 'with', found.length, 'entries')

  if (CARTOONIZE_API_URL) {
    console.log('CARTOONIZE_API_URL set — will POST image paths to', CARTOONIZE_API_URL)
    // Minimal scaffold: post filenames to API (not file bytes) so external services can pick up.
    try {
      const https = require('https')
      const url = new URL(CARTOONIZE_API_URL)
      const payload = JSON.stringify({ images: found.map(f => f.path) })
      const opts = { hostname: url.hostname, port: url.port || 443, path: url.pathname, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) } }
      const req = https.request(opts, (res) => { console.log('Cartoonize API responded', res.statusCode) })
      req.on('error', (e) => console.error('Cartoonize API request failed', e.message))
      req.write(payload)
      req.end()
    } catch (e) {
      console.error('Failed to call CARTOONIZE_API_URL', e && e.message)
    }
  }

  // Optionally POST raw image bytes if CARTOONIZE_API_URL_BYTES is set (and node fetch is available)
  const BYTES_API = process.env.CARTOONIZE_API_URL_BYTES || ''
  const API_KEY = process.env.CARTOONIZE_API_KEY || ''
  if (BYTES_API) {
    console.log('CARTOONIZE_API_URL_BYTES set — uploading image bytes')
    try {
      const fetch = global.fetch || require('node-fetch')
      for (const f of found) {
        try {
          const fp = path.join(__dirname, '..', 'public', f.path)
          const buf = fs.readFileSync(fp)
          const res = await fetch(BYTES_API, { method: 'POST', headers: { 'Content-Type': 'application/octet-stream', 'X-Filename': f.name, ...(API_KEY ? { 'Authorization': `Bearer ${API_KEY}` } : {}) }, body: buf })
          console.log('Uploaded', f.name, 'status', res.status)
        } catch (e) { console.error('Upload failed for', f.name, e && e.message) }
      }
    } catch (e) { console.error('Failed to POST bytes to CARTOONIZE_API_URL_BYTES', e && e.message) }
  }
} catch (e) {
  console.error('Error scanning images', e)
  process.exit(2)
}
