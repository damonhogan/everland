const fs = require('fs')
const path = require('path')
const { spawnSync } = require('child_process')

const idxPath = path.join(__dirname, '..', 'public', 'bbs', 'youtube_index.json')
const pendingPath = path.join(__dirname, '..', 'public', 'bbs', 'pending_assets.json')

function splitSentences(text) {
  if (!text) return []
  return text.replace(/\n+/g, ' ').split(/[.?!]\s+/).map(s=>s.trim()).filter(Boolean)
}

function findOaths(lines) {
  const oathRe = /\b(I\s+(?:swear|vow|promise|pledge|take an oath|do solemnly))\b/i
  return lines.filter(l => oathRe.test(l)).slice(0,5)
}

function ensureDir(d) { if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true }) }

function runTranscribeIfMissing(audioAbs) {
  const txtGuess = audioAbs.replace(/\.[^.]+$/, '.txt')
  if (fs.existsSync(txtGuess)) return txtGuess
  try {
    // call the provided transcribe wrapper which will use whisper if available
    const res = spawnSync(process.execPath, [path.join(__dirname, 'transcribe.js'), audioAbs], { stdio: 'inherit' })
    if (res.status !== 0) return null
    if (fs.existsSync(txtGuess)) return txtGuess
  } catch (e) {}
  return null
}

function run() {
  if (!fs.existsSync(idxPath)) { console.error('No youtube_index.json found'); process.exit(1) }
  const idx = JSON.parse(fs.readFileSync(idxPath,'utf8'))
  const out = { generatedAt: Date.now(), items: [] }
  for (const v of (idx.videos||[])) {
    const id = v.id
    const candidates = []
    if (v.audio) candidates.push({ type: 'audio', id: 'audio_'+id, title: v.title, src: '/' + v.audio, source: 'youtube' })
    if (v.thumbnail) candidates.push({ type: 'image', id: 'image_'+id, title: v.title, src: '/' + v.thumbnail, source: 'youtube' })

    // attempt to transcribe audio and extract lines
    if (v.audio) {
      const audioAbs = path.join(__dirname, '..', 'public', v.audio)
      const txt = runTranscribeIfMissing(audioAbs)
      let transcript = ''
      if (txt && fs.existsSync(txt)) {
        transcript = fs.readFileSync(txt, 'utf8')
      }
      if (transcript) {
        const lines = splitSentences(transcript)
        const top = lines.slice(0, 12)
        if (top.length) candidates.push({ type: 'npc_lines', id: 'npc_'+id, title: v.title, suggestedLines: top, source: 'youtube' })
        const oaths = findOaths(lines)
        if (oaths.length) candidates.push({ type: 'oath', id: 'oath_'+id, title: v.title + ' (oaths)', suggestedLines: oaths, source: 'youtube' })
      }
    }

    // also include short lines from title/desc
    const titleDesc = ((v.desc||'') + '\n' + (v.title||'')).trim()
    if (titleDesc) {
      const short = splitSentences(titleDesc).slice(0,4)
      if (short.length) candidates.push({ type: 'npc_lines', id: 'npcmeta_'+id, title: v.title, suggestedLines: short, source: 'youtube' })
    }

    out.items.push({ videoId: id, publishedAt: v.publishedAt, candidates })
  }
  fs.writeFileSync(pendingPath, JSON.stringify(out, null, 2))
  console.log('Wrote pending assets to', pendingPath)
}

run()
