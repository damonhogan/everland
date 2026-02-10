const fs = require('fs')
const path = require('path')

const youtubeIndex = path.join(__dirname, '..', 'public', 'bbs', 'youtube_index.json')
const pendingFile = path.join(__dirname, '..', 'public', 'bbs', 'pending_assets.json')

function shortLines(text, max=3) {
  if (!text) return []
  const s = text.replace(/\n+/g,' ').split(/[.?!]\s+/).map(x=>x.trim()).filter(Boolean)
  return s.slice(0,max)
}

function run() {
  if (!fs.existsSync(youtubeIndex)) { console.error('No youtube_index.json found'); process.exit(1) }
  const idx = JSON.parse(fs.readFileSync(youtubeIndex,'utf8'))
  const out = { generatedAt: Date.now(), items: [] }
  for (const v of (idx.videos||[])) {
    const id = v.id
    const candidates = []
    // audio candidate
    if (v.audio) candidates.push({ type: 'audio', id: 'audio_'+id, title: v.title, src: '/' + v.audio, suggestedTags: ['ambience','youtube'], source: 'youtube' })
    // thumbnail candidate
    if (v.thumbnail) candidates.push({ type: 'image', id: 'image_'+id, title: v.title, src: '/' + v.thumbnail, suggestedTags: ['thumbnail','cartoonize'], source: 'youtube' })
    // npc text candidates from title/desc
    const lines = shortLines((v.desc || '') + '\n' + (v.title || ''), 4)
    if (lines.length > 0) candidates.push({ type: 'npc_lines', id: 'npc_'+id, title: v.title, suggestedLines: lines, source: 'youtube' })

    out.items.push({ videoId: id, publishedAt: v.publishedAt, candidates })
  }
  fs.writeFileSync(pendingFile, JSON.stringify(out, null, 2))
  console.log('Wrote pending assets to', pendingFile)
}

run()
