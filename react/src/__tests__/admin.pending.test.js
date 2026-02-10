import { spawn } from 'child_process'
import path from 'path'
import fs from 'fs'
import fetch from 'node-fetch'
import getPort from 'get-port'

const root = path.resolve(__dirname, '..', '..')
let serverProc
let port
const serverUrl = () => `http://localhost:${port}`

async function startServer() {
  port = await getPort({ port: getPort.makeRange(3001, 3010) })
  serverProc = spawn('node', ['server.js'], { cwd: path.join(root, 'react'), env: { ...process.env, PORT: String(port) }, stdio: ['ignore', 'pipe', 'pipe'] })
  return new Promise((resolve, reject) => {
    const t = setTimeout(() => reject(new Error('server did not start in time')), 15000)
    serverProc.stdout.on('data', d => {
      const s = d.toString()
      if (s.includes('listening') || s.includes('Server started') || s.includes('mock api')) {
        clearTimeout(t); resolve()
      }
    })
    serverProc.on('error', e => { clearTimeout(t); reject(e) })
  })
}

async function stopServer() {
  if (serverProc) {
    serverProc.kill()
    serverProc = null
  }
}

beforeAll(async () => { await startServer() })
afterAll(async () => { await stopServer() })

test('admin pending list and approve flow', async () => {
  const pendingPath = path.join(root, 'react', 'public', 'bbs', 'pending_assets.json')
  // prepare a pending file
  const pending = { items: [ { videoId: 'vid123', title: 'Test Video', candidates: [ { id: 'c1', type: 'audio', title: 'Audio Candidate', src: '/bbs/music/test.mp3' }, { id: 'c2', type: 'npc_lines', title: 'NPC Candidate', suggestedLines: ['Line one','Line two'] } ] } ] }
  fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2))

  // call listing
  const listRes = await fetch(serverUrl() + '/api/admin/pending')
  expect(listRes.ok).toBe(true)
  const listJson = await listRes.json()
  expect(Array.isArray(listJson.items)).toBe(true)
  expect(listJson.items.length).toBeGreaterThan(0)

  // approve audio candidate
  const approveRes = await fetch(serverUrl() + '/api/admin/approve', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ videoId: 'vid123', candidateId: 'c1', publishTo: 'audio' }) })
  expect(approveRes.ok).toBe(true)
  const audioPath = path.join(root, 'react', 'public', 'bbs', 'audio_assets.json')
  const audio = JSON.parse(fs.readFileSync(audioPath,'utf8'))
  expect(Array.isArray(audio.tracks)).toBe(true)
  expect(audio.tracks.find(t=>t.id==='c1')).toBeTruthy()

  // approve npc -> npc_cards
  const approveNpc = await fetch(serverUrl() + '/api/admin/approve', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ videoId: 'vid123', candidateId: 'c2', publishTo: 'npc_lines' }) })
  expect(approveNpc.ok).toBe(true)
  const npcsPath = path.join(root, 'react', 'public', 'bbs', 'npcs_cards.json')
  const npcs = JSON.parse(fs.readFileSync(npcsPath,'utf8'))
  expect(Array.isArray(npcs)).toBe(true)
  expect(npcs.find(n=>n.id && n.name)).toBeTruthy()

  // approve npc as scene
  fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2))
  const approveScene = await fetch(serverUrl() + '/api/admin/approve', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ videoId: 'vid123', candidateId: 'c2', publishTo: 'scene' }) })
  expect(approveScene.ok).toBe(true)
  const scenesPath = path.join(root, 'react', 'public', 'bbs', 'lore_scenes.json')
  const scenes = JSON.parse(fs.readFileSync(scenesPath,'utf8'))
  expect(Array.isArray(scenes)).toBe(true)
  expect(scenes.find(s=>s.id && s.steps && s.steps.length>0)).toBeTruthy()

})
