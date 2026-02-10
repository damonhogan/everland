const { spawn } = require('child_process')
const path = require('path')
const fs = require('fs')

const root = path.resolve(__dirname, '..')
const reactRoot = path.join(root)
const port = process.env.PORT || 3001
const serverUrl = (p) => `http://localhost:${port}${p}`

function waitFor(url, timeout=10000) {
  const start = Date.now()
  return new Promise((resolve, reject) => {
    (function poll(){
      fetch(url).then(r=>{ if (r.ok) resolve(); else throw new Error('not ok') }).catch(e=>{
        if (Date.now()-start > timeout) return reject(new Error('timeout'))
        setTimeout(poll, 200)
      })
    })()
  })
}

async function run(){
  console.log('Starting server...')
  const server = spawn(process.execPath, ['server.js'], { cwd: reactRoot, env: { ...process.env, PORT: String(port) }, stdio: ['ignore','inherit','inherit'] })
  try{
    await waitFor(serverUrl('/api/admin/pending'), 15000)
  } catch(e){
    console.error('Server did not become ready:', e)
    server.kill()
    process.exit(1)
  }

  const pendingPath = path.join(reactRoot, 'public','bbs','pending_assets.json')
  const pending = { items: [ { videoId: 'vid_test', title: 'Test Video', candidates: [ { id: 'ca1', type: 'audio', title: 'Audio Candidate', src: '/bbs/music/test.mp3' }, { id: 'c2', type: 'npc_lines', title: 'NPC Candidate', suggestedLines: ['Say hello','Do a thing'] } ] } ] }
  fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2))

  console.log('Listing pending...')
  let res = await fetch(serverUrl('/api/admin/pending'))
  console.log('list status', res.status)
  const list = await res.json()
  console.log('pending items', (list.items||[]).length)

  console.log('Approving audio candidate...')
  res = await fetch(serverUrl('/api/admin/approve'), { method: 'POST', headers: { 'content-type':'application/json' }, body: JSON.stringify({ videoId:'vid_test', candidateId:'ca1', publishTo:'audio' }) })
  console.log('approve audio status', res.status)

  const audioPath = path.join(reactRoot, 'public','bbs','audio_assets.json')
  console.log('audio exists', fs.existsSync(audioPath))

  // re-create pending for npc approvals
  fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2))
  console.log('Approving npc candidate as npc_lines...')
  res = await fetch(serverUrl('/api/admin/approve'), { method: 'POST', headers: { 'content-type':'application/json' }, body: JSON.stringify({ videoId:'vid_test', candidateId:'c2', publishTo:'npc_lines' }) })
  console.log('approve npc status', res.status)
  const npcsPath = path.join(reactRoot, 'public','bbs','npcs_cards.json')
  console.log('npcs exists', fs.existsSync(npcsPath))

  fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2))
  console.log('Approving npc candidate as scene...')
  res = await fetch(serverUrl('/api/admin/approve'), { method: 'POST', headers: { 'content-type':'application/json' }, body: JSON.stringify({ videoId:'vid_test', candidateId:'c2', publishTo:'scene' }) })
  console.log('approve scene status', res.status)
  const scenesPath = path.join(reactRoot, 'public','bbs','lore_scenes.json')
  console.log('scenes exists', fs.existsSync(scenesPath))

  console.log('Done. Shutting down server.')
  server.kill()
}

run().catch(e=>{ console.error(e); process.exit(1) })
