const fs = require('fs')
const path = require('path')
const https = require('https')

// Simple audio ingest script: reads audio_sources.json and downloads listed URLs
// Placeholders only — converting or re-encoding requires ffmpeg installed.

const cfgPath = path.join(__dirname, '..', 'public', 'bbs', 'audio_sources.json')
const outDir = path.join(__dirname, '..', 'public', 'music')

if (!fs.existsSync(cfgPath)) {
  console.error('No audio_sources.json found at', cfgPath)
  process.exit(1)
}

const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'))
if (!Array.isArray(cfg.sources)) {
  console.error('audio_sources.json must contain { sources: [ {id, url} ] }')
  process.exit(1)
}

if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true })

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest)
    https.get(url, res => {
      if (res.statusCode !== 200) return reject(new Error('HTTP ' + res.statusCode))
      res.pipe(file)
      file.on('finish', () => { file.close(resolve) })
    }).on('error', (e) => { fs.unlink(dest, ()=>{}); reject(e) })
  })
}

;(async () => {
  for (const s of cfg.sources) {
    try {
      const filename = path.basename(new URL(s.url).pathname)
      const dest = path.join(outDir, filename)
      console.log('Downloading', s.url, '->', dest)
      await download(s.url, dest)
      console.log('Saved', dest)
      // if ffmpeg is available, also convert to a normalized mp3 copy
      try {
        const { spawnSync } = require('child_process')
        const outMp3 = path.join(outDir, path.parse(filename).name + '.mp3')
        const which = spawnSync('ffmpeg', ['-version'])
        if (which.status === 0) {
          console.log('ffmpeg found — converting', dest, '->', outMp3)
          const conv = spawnSync('ffmpeg', ['-y', '-i', dest, '-b:a', '128k', outMp3], { stdio: 'inherit' })
          if (conv.status === 0) console.log('Converted to', outMp3)
          else console.warn('ffmpeg conversion failed for', dest)
        } else {
          // ffmpeg not present
        }
      } catch (e) {}
    } catch (e) {
      console.error('Failed to download', s && s.url, e && e.message)
    }
  }
  console.log('Ingest complete')
})()
