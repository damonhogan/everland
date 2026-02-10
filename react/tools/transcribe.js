const { spawnSync } = require('child_process')
const fs = require('fs')
const path = require('path')

// Simple transcription wrapper: tries Whisper CLI if available, otherwise prints instructions.
// Usage: node tools/transcribe.js path/to/audio.mp3

const file = process.argv[2]
if (!file) { console.error('Usage: node tools/transcribe.js <audiofile>'); process.exit(1) }
if (!fs.existsSync(file)) { console.error('File not found:', file); process.exit(2) }

try {
  const check = spawnSync('whisper', ['--help'], { stdio: 'ignore' })
  if (check.status === 0) {
    console.log('Using whisper CLI to transcribe', file)
    const out = spawnSync('whisper', [file, '--model', 'small', '--language', 'en', '--output_format', 'txt'], { stdio: 'inherit' })
    process.exit(out.status || 0)
  }
} catch (e) {}

console.log('Whisper CLI not found. You can install it or use an external ASR provider.')
console.log('If you have OpenAI or other ASR, you can implement a small script to call it here.')
