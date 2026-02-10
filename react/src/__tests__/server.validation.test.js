/**
 * @vitest-environment node
 */

import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { spawn } from 'child_process'
import fetch from 'node-fetch'

let server = null

beforeAll(async () => {
  server = spawn(process.execPath, ['server.js'], { cwd: process.cwd(), stdio: ['ignore', 'pipe', 'pipe'] })
  // poll server health via GET /api/quests
  const deadline = Date.now() + 5000
  while (Date.now() < deadline) {
    try {
      const r = await fetch('http://localhost:3001/api/quests')
      if (r.ok) return
    } catch (e) {
      // ignore and retry
    }
    await new Promise((r) => setTimeout(r, 100))
  }
  throw new Error('server did not start')
})

afterAll(() => {
  if (server) server.kill()
})

describe('server validation', () => {
  it('accepts valid quests array', async () => {
    const q = [{ id: 1, title: 'Q1', state: 'in_progress' }]
    const r = await fetch('http://localhost:3001/api/quests', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(q) })
    expect(r.status).toBe(200)
    const jb = await r.json()
    expect(jb.ok).toBe(true)
  })

  it('rejects invalid quest with structured errors', async () => {
    const bad = [{ title: 'missing id' }]
    const r = await fetch('http://localhost:3001/api/quests', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(bad) })
    expect(r.status).toBe(400)
    const jb = await r.json()
    expect(jb.ok).toBe(false)
    expect(Array.isArray(jb.errors)).toBe(true)
    expect(jb.errors[0]).toHaveProperty('message')
  })

  it('applies valid accept action and returns canonical quests', async () => {
    // seed
    await fetch('http://localhost:3001/api/quests', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify([{ id: 10, title: 'T' }]) })
    const action = { action: { type: 'accept', payload: { id: 10 } } }
    const r = await fetch('http://localhost:3001/api/quests/actions', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(action) })
    expect(r.status).toBe(200)
    const jb = await r.json()
    expect(jb.ok).toBe(true)
    expect(Array.isArray(jb.quests)).toBe(true)
    expect(jb.quests[0].state).toBe('accepted')
  })

  it('rejects unknown action types', async () => {
    const r = await fetch('http://localhost:3001/api/quests/actions', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action: { type: 'unknown' } }) })
    expect(r.status).toBe(400)
    const jb = await r.json()
    expect(Array.isArray(jb.errors)).toBe(true)
  })

  it('rejects replace action with invalid quest payload', async () => {
    const bad = { action: { type: 'replace', payload: [{ title: 'no id' }] } }
    const r = await fetch('http://localhost:3001/api/quests/actions', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(bad) })
    expect(r.status).toBe(400)
    const jb = await r.json()
    expect(Array.isArray(jb.errors)).toBe(true)
  })
})
