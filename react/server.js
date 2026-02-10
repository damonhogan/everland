const express = require('express')
const bodyParser = require('body-parser')
const Ajv = require('ajv')
const ajv = new Ajv({ allErrors: true, strict: false })

const app = express()
const port = process.env.PORT || 3001

app.use(bodyParser.json({ limit: '1mb' }))
const path = require('path')

// debug: log all incoming requests (tests rely on this)
app.use((req, res, next) => { try { console.log('REQ', req.method, req.url); } catch(e){}; next() })

// serve static public files so audio and bbs assets are available
app.use('/bbs', express.static(path.join(__dirname, 'public', 'bbs')))
app.use('/music', express.static(path.join(__dirname, 'public', 'music')))

// simple in-memory store for quests (for integration/dev)
let storedQuests = []
let storedRumors = []
// persistent storage for tokens and rumors
const dataDir = path.join(__dirname, 'data')
if (!require('fs').existsSync(dataDir)) require('fs').mkdirSync(dataDir, { recursive: true })
const tokensFile = path.join(dataDir, 'gm_tokens.json')
const rumorsFile = path.join(dataDir, 'rumors.json')

function loadJson(file, fallback) {
  try { if (require('fs').existsSync(file)) return JSON.parse(require('fs').readFileSync(file, 'utf8')) } catch (e) {}
  return fallback
}

let gmTokens = loadJson(tokensFile, [])
storedRumors = loadJson(rumorsFile, [])

function saveTokens() { try { require('fs').writeFileSync(tokensFile, JSON.stringify(gmTokens, null, 2)) } catch (e) {} }
function saveRumors() { try { require('fs').writeFileSync(rumorsFile, JSON.stringify(storedRumors, null, 2)) } catch (e) {} }

// JSON Schemas
const questStates = ['available', 'in_progress', 'accepted', 'completed', 'failed']

const triggerSchema = {
  type: 'object',
  required: ['type'],
  properties: {
    type: { type: 'string', enum: ['event', 'time', 'item'] },
    params: { type: 'object' }
  },
  additionalProperties: true
}

const prereqSchema = {
  type: 'object',
  required: ['id'],
  properties: {
    id: { anyOf: [{ type: 'string' }, { type: 'number' }] },
    type: { type: 'string', enum: ['quest', 'item'] },
    count: { type: 'number', minimum: 0 }
  },
  additionalProperties: false
}

const questSchema = {
  type: 'object',
  required: ['id', 'title'],
  properties: {
    id: { anyOf: [{ type: 'string' }, { type: 'number' }] },
    title: { type: 'string', minLength: 1 },
    state: { type: 'string', enum: questStates },
    completed: { type: 'boolean' },
    progress: { type: 'number', minimum: 0 },
    triggers: { type: 'array', items: triggerSchema },
    prerequisites: { type: 'array', items: prereqSchema }
  },
  additionalProperties: true
}

const questsSchema = { type: 'array', items: questSchema }

const actionTypes = ['replace','set_all','accept','complete','add_trigger','clear_triggers','update_prereqs','increment']

const actionSchema = {
  type: 'object',
  required: ['type'],
  properties: {
    type: { type: 'string', enum: actionTypes },
    payload: {}
  },
  allOf: [
    {
      if: { properties: { type: { const: 'replace' } } },
      then: { properties: { payload: { type: 'array', items: questSchema } }, required: ['payload'] }
    },
    {
      if: { properties: { type: { const: 'set_all' } } },
      then: { properties: { payload: { type: 'array', items: questSchema } }, required: ['payload'] }
    },
    {
      if: { properties: { type: { const: 'accept' } } },
      then: { properties: { payload: { type: 'object', properties: { id: { anyOf: [{ type: 'string' }, { type: 'number' }] } }, required: ['id'] } }, required: ['payload'] }
    },
    {
      if: { properties: { type: { const: 'add_trigger' } } },
      then: { properties: { payload: { type: 'object', properties: { id: { anyOf: [{ type: 'string' }, { type: 'number' }] }, trigger: triggerSchema }, required: ['id','trigger'] } }, required: ['payload'] }
    },
    {
      if: { properties: { type: { const: 'clear_triggers' } } },
      then: { properties: { payload: { type: 'object', properties: { id: { anyOf: [{ type: 'string' }, { type: 'number' }] } }, required: ['id'] } }, required: ['payload'] }
    },
    {
      if: { properties: { type: { const: 'update_prereqs' } } },
      then: { properties: { payload: { type: 'object', properties: { id: { anyOf: [{ type: 'string' }, { type: 'number' }] }, prerequisites: { type: 'array', items: prereqSchema } }, required: ['id','prerequisites'] } }, required: ['payload'] }
    },
    {
      if: { properties: { type: { const: 'increment' } } },
      then: { properties: { payload: { type: 'object', properties: { id: { anyOf: [{ type: 'string' }, { type: 'number' }] }, by: { type: 'number' } }, required: ['id'] } }, required: ['payload'] }
    }
  ]
}

const validateQuests = ajv.compile(questsSchema)
const validateAction = ajv.compile(actionSchema)

function formatAjvErrors(errors) {
  return (errors || []).map(e => ({ path: e.instancePath || e.dataPath || '', message: e.message || '', keyword: e.keyword, params: e.params }))
}

app.post('/api/quests', (req, res) => {
  const q = req.body
  if (!q) return res.status(400).json({ error: 'Missing body' })
  if (!Array.isArray(q)) return res.status(400).json({ error: 'Body must be an array of quests' })
  const valid = validateQuests(q)
  if (!valid) return res.status(400).json({ ok: false, errors: formatAjvErrors(validateQuests.errors) })
  storedQuests = q
  console.log('Received quests:', Array.isArray(q) ? q.length : 'unknown')
  return res.status(200).json({ ok: true })
})

app.get('/api/quests', (req, res) => {
  res.json(storedQuests)
})

// Server-side action endpoint: validates and applies a single action
app.post('/api/quests/actions', (req, res) => {
  const payload = req.body
  if (!payload || !payload.action) return res.status(400).json({ ok: false, error: 'Missing action' })
  const action = payload.action

  const okAction = validateAction(action)
  if (!okAction) return res.status(400).json({ ok: false, errors: formatAjvErrors(validateAction.errors) })

  // reducer implementation (mirrors client)
  function reducer(current, act) {
    if (!Array.isArray(current)) current = []
    switch (act.type) {
      case 'replace':
      case 'set_all':
        return Array.isArray(act.payload) ? act.payload : current
      case 'accept': {
        const id = act.payload?.id
        return current.map(q => q.id === id ? { ...q, state: 'accepted' } : q)
      }
      case 'complete': {
        const id = act.payload?.id
        return current.map(q => q.id === id ? { ...q, completed: true, state: 'completed' } : q)
      }
      case 'add_trigger': {
        const { id, trigger } = act.payload || {}
        return current.map(q => q.id === id ? { ...q, triggers: [ ...(q.triggers||[]), trigger ] } : q)
      }
      case 'clear_triggers': {
        const id = act.payload?.id
        return current.map(q => q.id === id ? { ...q, triggers: [] } : q)
      }
      case 'update_prereqs': {
        const { id, prerequisites } = act.payload || {}
        return current.map(q => q.id === id ? { ...q, prerequisites } : q)
      }
      case 'increment': {
        const { id, by } = act.payload || {}
        return current.map(q => q.id === id ? { ...q, progress: (q.progress||0) + (typeof by === 'number' ? by : 1) } : q)
      }
      default:
        return current
    }
  }

  try {
    const next = reducer(storedQuests, action)
    const ok = validateQuests(next)
    if (!ok) return res.status(400).json({ ok: false, errors: formatAjvErrors(validateQuests.errors) })
    storedQuests = next
    return res.status(200).json({ ok: true, quests: storedQuests })
  } catch (e) {
    return res.status(500).json({ ok: false, error: String(e) })
  }
})

// GM endpoints: accept rumor broadcasts and list recent rumors
app.post('/api/gm/rumor', (req, res) => {
  const { text, source } = req.body || {}
  const GM_TOKEN = process.env.GM_TOKEN || ''
  if (GM_TOKEN) {
    const provided = (req.headers['x-gm-token'] || '')
    if (!provided || String(provided) !== GM_TOKEN) return res.status(403).json({ ok: false, error: 'GM token required' })
  }
  if (!text || typeof text !== 'string') return res.status(400).json({ ok: false, error: 'Missing rumor text' })
  const entry = { id: Date.now().toString(36) + Math.floor(Math.random()*1000), text: String(text), source: source || 'gm', time: Date.now() }
  storedRumors.unshift(entry)
  // cap
  if (storedRumors.length > 100) storedRumors.length = 100
  // broadcast to any websocket clients if available
  try { if (app.locals && typeof app.locals.wssBroadcast === 'function') app.locals.wssBroadcast({ type: 'rumor', rumor: entry }) } catch (e) {}
  saveRumors()
  return res.status(200).json({ ok: true, rumor: entry })
})

app.get('/api/gm/rumors', (req, res) => {
  res.json(storedRumors.slice(0,50))
})

// Admin token management endpoints protected by ADMIN_SECRET env var (x-admin-secret header)
app.get('/api/gm/tokens', (req, res) => {
  const ADMIN_SECRET = process.env.ADMIN_SECRET || ''
  if (ADMIN_SECRET) {
    const provided = req.headers['x-admin-secret'] || ''
    if (!provided || String(provided) !== ADMIN_SECRET) return res.status(403).json({ ok: false, error: 'admin secret required' })
  }
  // return tokens metadata (id, label, token)
  return res.json(gmTokens.map(t => ({ id: t.id, label: t.label, token: t.token })))
})

app.post('/api/gm/tokens', (req, res) => {
  console.log('POST /api/gm/tokens incoming')
  const ADMIN_SECRET = process.env.ADMIN_SECRET || ''
  if (ADMIN_SECRET) {
    const provided = req.headers['x-admin-secret'] || ''
    if (!provided || String(provided) !== ADMIN_SECRET) return res.status(403).json({ ok: false, error: 'admin secret required' })
  }
  const { label } = req.body || {}
  const id = Date.now().toString(36) + Math.floor(Math.random()*1000)
  const token = Math.random().toString(36).slice(2) + Math.random().toString(36).slice(2)
  const entry = { id, label: label || '', token }
  gmTokens.push(entry)
  saveTokens()
  return res.status(201).json(entry)
})

app.delete('/api/gm/tokens/:id', (req, res) => {
  const ADMIN_SECRET = process.env.ADMIN_SECRET || ''
  if (ADMIN_SECRET) {
    const provided = req.headers['x-admin-secret'] || ''
    if (!provided || String(provided) !== ADMIN_SECRET) return res.status(403).json({ ok: false, error: 'admin secret required' })
  }
  const id = req.params.id
  const idx = gmTokens.findIndex(t => t.id === id)
  if (idx === -1) return res.status(404).json({ ok: false, error: 'not found' })
  gmTokens.splice(idx, 1)
  saveTokens()
  return res.json({ ok: true })
})

// Admin endpoints for pending assets produced by youtube ingest/merge script
app.get('/api/admin/pending', (req, res) => {
  const ADMIN_SECRET = process.env.ADMIN_SECRET || ''
  if (ADMIN_SECRET) {
    const provided = req.headers['x-admin-secret'] || ''
    if (!provided || String(provided) !== ADMIN_SECRET) return res.status(403).json({ ok: false, error: 'admin secret required' })
  }
  const pendingPath = path.join(__dirname, 'public', 'bbs', 'pending_assets.json')
  if (!require('fs').existsSync(pendingPath)) return res.json({ items: [] })
  try { const j = JSON.parse(require('fs').readFileSync(pendingPath, 'utf8')); return res.json(j) } catch (e) { return res.status(500).json({ ok:false, error: String(e) }) }
})

app.post('/api/admin/approve', (req, res) => {
  const ADMIN_SECRET = process.env.ADMIN_SECRET || ''
  if (ADMIN_SECRET) {
    const provided = req.headers['x-admin-secret'] || ''
    if (!provided || String(provided) !== ADMIN_SECRET) return res.status(403).json({ ok: false, error: 'admin secret required' })
  }
  const { videoId, candidateId, publishTo } = req.body || {}
  if (!videoId || !candidateId || !publishTo) return res.status(400).json({ ok:false, error:'videoId, candidateId and publishTo required' })
  const pendingPath = path.join(__dirname, 'public', 'bbs', 'pending_assets.json')
  if (!require('fs').existsSync(pendingPath)) return res.status(404).json({ ok:false, error:'no pending file' })
  const pending = JSON.parse(require('fs').readFileSync(pendingPath,'utf8'))
  const entry = (pending.items||[]).find(it => it.videoId === videoId)
  if (!entry) return res.status(404).json({ ok:false, error:'video not found' })
  const candidate = (entry.candidates || []).find(c => c.id === candidateId || c.id === candidateId.toString())
  if (!candidate) return res.status(404).json({ ok:false, error:'candidate not found' })
  // merge based on publishTo: 'audio', 'image', 'npc'
  try {
    if (publishTo === 'audio' && candidate.type === 'audio') {
      const audioPath = path.join(__dirname, 'public', 'bbs', 'audio_assets.json')
      const aud = require('fs').existsSync(audioPath) ? JSON.parse(require('fs').readFileSync(audioPath,'utf8')) : { tracks: [] }
      aud.tracks.unshift({ id: candidate.id, title: candidate.title, src: candidate.src, description: candidate.title })
      require('fs').writeFileSync(audioPath, JSON.stringify(aud, null, 2))
    }
    if (publishTo === 'image' && candidate.type === 'image') {
      // no-op: images are already under public/images; we could add indexing elsewhere
    }
    if (publishTo === 'npc_lines' && candidate.type === 'npc_lines') {
      const npcsPath = path.join(__dirname, 'public', 'bbs', 'npcs_cards.json')
      const npcs = require('fs').existsSync(npcsPath) ? JSON.parse(require('fs').readFileSync(npcsPath,'utf8')) : []
      // create a simple NPC entry
      npcs.unshift({ id: 'yt_'+videoId, name: candidate.title.slice(0,30), role: 'Derived', short_blurb: candidate.title, voice_lines: candidate.suggestedLines || [], costume: 'Derived from video' })
      require('fs').writeFileSync(npcsPath, JSON.stringify(npcs, null, 2))
    }
    if ((publishTo === 'scene' || publishTo === 'lore_scene') && candidate.type === 'npc_lines') {
      const scenesPath = path.join(__dirname, 'public', 'bbs', 'lore_scenes.json')
      const scenesRaw = require('fs').existsSync(scenesPath) ? JSON.parse(require('fs').readFileSync(scenesPath,'utf8')) : []
      const scenes = Array.isArray(scenesRaw) ? scenesRaw : []
      // build a richer scene template using suggestedLines as steps and optional metadata
      const scene = {
        id: 'yt_scene_' + videoId,
        title: candidate.title,
        description: candidate.description || candidate.title,
        location: candidate.location || 'Unknown',
        npc_refs: candidate.npc_refs || candidate.npcIds || [],
        tags: candidate.tags || [],
        steps: (candidate.suggestedLines || []).map((t, i) => ({ id: i+1, text: t }))
      }
      scenes.unshift(scene)
      require('fs').writeFileSync(scenesPath, JSON.stringify(scenes, null, 2))
    }
    // remove candidate from pending
    const newItems = (pending.items||[]).map(it => it.videoId === videoId ? { ...it, candidates: (it.candidates||[]).filter(c=>c.id !== candidate.id) } : it)
    const newPending = { ...pending, items: newItems }
    require('fs').writeFileSync(pendingPath, JSON.stringify(newPending, null, 2))
    return res.json({ ok:true })
  } catch (e) { console.error('Error in /api/admin/approve:', e); return res.status(500).json({ ok:false, error: String(e) }) }
})

// create a plain http server so we can attach a WebSocket server
const http = require('http')
const server = http.createServer(app)

// WebSocket server for GM broadcasts
try {
  const WebSocket = require('ws')
  const url = require('url')
  const wss = new WebSocket.Server({ server })
  wss.on('connection', (ws, req) => {
    try {
      // parse optional token from query string
      const parsed = url.parse(req.url || '', true)
      const token = parsed.query && parsed.query.token ? String(parsed.query.token) : ''
      const GM_TOKEN = process.env.GM_TOKEN || ''
      ws.isGM = (GM_TOKEN && token && token === GM_TOKEN) || false
      ws.send(JSON.stringify({ type: 'hello', time: Date.now(), isGM: !!ws.isGM }))
    } catch (e) {}
  })

  // attach a simple broadcast helper
  app.locals.wssBroadcast = function (msg) {
    try {
      const data = typeof msg === 'string' ? msg : JSON.stringify(msg)
      wss.clients.forEach(c => { if (c.readyState === WebSocket.OPEN) c.send(data) })
    } catch (e) {}
  }
} catch (e) {
  // if ws isn't installed, continue without websockets
  console.warn('WebSocket support not available (ws missing)')
}

server.listen(port, () => {
  console.log(`Mock server listening on http://localhost:${port}`)
  try {
    const routes = (app._router && app._router.stack) ? app._router.stack.filter(s => s.route).map(s => Object.keys(s.route.methods).join(',') + ' ' + s.route.path) : []
    console.log('ROUTES:', routes)
  } catch (e) {}
})
