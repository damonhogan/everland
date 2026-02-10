const fs = require('fs')
const path = require('path')
const https = require('https')
const { spawnSync } = require('child_process')

// Usage: set env YT_API_KEY and run with channel id
// Example: YT_API_KEY=XXX node tools/youtube_ingest.js UCMXCPPNbXi8qchjzxUUaI4A

const API_KEY = process.env.YT_API_KEY || ''
const channelId = process.argv[2]
if (!channelId) {
  console.error('Usage: node tools/youtube_ingest.js <channelId>')
  process.exit(1)
}
if (!API_KEY) console.warn('Warning: YT_API_KEY not set — metadata fetch may fail')

const outDirImages = path.join(__dirname, '..', 'public', 'images')
const outDirMusic = path.join(__dirname, '..', 'public', 'music')
const outIndex = path.join(__dirname, '..', 'public', 'bbs', 'youtube_index.json')
if (!fs.existsSync(outDirImages)) fs.mkdirSync(outDirImages, { recursive: true })
if (!fs.existsSync(outDirMusic)) fs.mkdirSync(outDirMusic, { recursive: true })

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let s = ''
      res.on('data', d => s += d)
      res.on('end', () => { try { resolve(JSON.parse(s)) } catch (e) { reject(e) } })
    }).on('error', reject)
  })
}

async function listVideos() {
  if (!API_KEY) return []
  const url = `https://www.googleapis.com/youtube/v3/search?channelId=${channelId}&part=snippet&order=date&type=video&maxResults=50&key=${API_KEY}`
  try {
    const j = await fetchJson(url)
    const items = j.items || []
    return items.map(it => ({ id: it.id.videoId, title: it.snippet.title, desc: it.snippet.description, publishedAt: it.snippet.publishedAt, thumbnails: it.snippet.thumbnails }))
  } catch (e) {
    console.error('Failed to list videos:', e && e.message)
    return []
  }
}

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const f = fs.createWriteStream(dest)
    https.get(url, (res) => {
      if (res.statusCode !== 200) return reject(new Error('HTTP ' + res.statusCode))
      res.pipe(f)
      f.on('finish', () => { f.close(resolve) })
    }).on('error', (e) => { try { fs.unlinkSync(dest) } catch(e){}; reject(e) })
  })
}

async function downloadThumbnail(thUrl, id) {
  try {
    const urlObj = new URL(thUrl)
    const ext = path.extname(urlObj.pathname) || '.jpg'
    const dest = path.join(outDirImages, `${id}${ext}`)
    if (fs.existsSync(dest)) return dest
    await downloadFile(thUrl, dest)
    return dest
  } catch (e) { return null }
}

function downloadAudio(videoId) {
  try {
    const outTemplate = path.join(outDirMusic, `${videoId}.%(ext)s`)
    // yt-dlp must be installed and on PATH
    const args = ['-x', '--audio-format', 'mp3', '-o', outTemplate, `https://www.youtube.com/watch?v=${videoId}`]
    console.log('yt-dlp', args.join(' '))
    const res = spawnSync('yt-dlp', args, { stdio: 'inherit' })
    if (res.status !== 0) {
      console.warn('yt-dlp failed for', videoId)
      return null
    }
    const candidate = path.join(outDirMusic, `${videoId}.mp3`)
    if (fs.existsSync(candidate)) return candidate
    return null
  } catch (e) { console.error('audio download error', e && e.message); return null }
}

async function run() {
  console.log('Listing videos for channel', channelId)
  const vids = await listVideos()
  console.log('Found', vids.length, 'videos')
  const index = { generatedAt: Date.now(), channelId, videos: [] }
  for (const v of vids) {
    const meta = { id: v.id, title: v.title, desc: v.desc, publishedAt: v.publishedAt }
    // thumbnail
    const th = v.thumbnails && (v.thumbnails.maxres || v.thumbnails.high || v.thumbnails.default)
    if (th && th.url) {
      const tdest = await downloadThumbnail(th.url, v.id)
      if (tdest) meta.thumbnail = path.relative(path.join(__dirname, '..', 'public'), tdest).replace(/\\/g, '/')
    }
    // audio
    const a = downloadAudio(v.id)
    if (a) meta.audio = path.relative(path.join(__dirname, '..', 'public'), a).replace(/\\/g, '/')
    index.videos.push(meta)
  }
  fs.writeFileSync(outIndex, JSON.stringify(index, null, 2))
  console.log('Wrote', outIndex)
}

run().catch(e => { console.error(e); process.exit(2) })
