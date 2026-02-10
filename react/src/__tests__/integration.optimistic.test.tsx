/**
 * @vitest-environment jsdom
 */

import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { act } from 'react'
import { GameDataProvider, useGameData } from '../context/GameDataContext'

import { spawn } from 'child_process'
import fetch from 'node-fetch'

function Consumer() {
  const gd = useGameData()
  ;(window as any).__gd = gd
  return null
}

describe('integration optimistic confirm/rollback', () => {
  let server: any = null
  let root: ReactDOM.Root | null = null
  const container = document.createElement('div')
  document.body.appendChild(container)

  beforeAll(async () => {
    // start server.js in react folder
    server = spawn(process.execPath, ['server.js'], { cwd: process.cwd(), stdio: ['ignore', 'pipe', 'pipe'] })
    // poll the server until it's reachable (GET /api/quests)
    const deadline = Date.now() + 5000
    while (Date.now() < deadline) {
      try {
        const r = await fetch('http://localhost:3001/api/quests')
        if (r.ok) return
      } catch (e) {
        // ignore and retry
      }
      await new Promise(r => setTimeout(r, 100))
    }
    throw new Error('server did not start')
  })

  afterAll(() => {
    if (server) server.kill()
    if (root) { root.unmount(); root = null }
  })

  it('optimistic confirm: server applies action and provider reflects canonical', async () => {
    // seed server with initial quests
    await fetch('http://localhost:3001/api/quests', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify([{ id: 1, title: 'T1', state: 'in_progress' }]) })

    // seed localStorage cache so provider uses it
    localStorage.setItem('everland_game_data', JSON.stringify({ ts: Date.now(), data: { items: {}, npcs: [], recipes: [], quests: [{ id: 1, title: 'T1', state: 'in_progress' }] } }))

    // ensure provider's relative fetch('/api/...') is routed to the mock server on 3001
    const origFetch = (global as any).fetch || fetch
    ;(global as any).fetch = (input: any, init?: any) => {
      const url = typeof input === 'string' ? input : (input && input.url) || ''
      if (typeof url === 'string' && url.startsWith('/api')) {
        return origFetch('http://localhost:3001' + url, init)
      }
      return origFetch(input, init)
    }

    await act(async () => {
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <Consumer />
        </GameDataProvider>
      )
    })

    // wait for provider to be ready
    await new Promise(r => setTimeout(r, 200))

    const gd = (window as any).__gd
    expect(gd.data.quests[0].state).toBe('in_progress')

    // dispatch accept action
    await act(async () => {
      gd.questsDispatch({ type: 'accept', payload: { id: 1 } })
    })

    // poll server for canonical state (timeout 2s)
    let serverQuests: any = null
    const deadline = Date.now() + 2000
    while (Date.now() < deadline) {
      const sr = await fetch('http://localhost:3001/api/quests')
      serverQuests = await sr.json()
      if (serverQuests?.[0]?.state === 'accepted') break
      await new Promise(r => setTimeout(r, 100))
    }
    expect(serverQuests?.[0]?.state).toBe('accepted')

    // provider should have been updated to server canonical
    expect((window as any).__gd.data.quests[0].state).toBe('accepted')
  })

  it('optimistic rollback and enqueue on invalid action', async () => {
    // prepare provider with single quest
    localStorage.setItem('everland_game_data', JSON.stringify({ ts: Date.now(), data: { items: {}, npcs: [], recipes: [], quests: [{ id: 2, title: 'T2', state: 'in_progress' }] } }))

    await act(async () => {
      // re-render provider to pick up cache
      if (root) { root.unmount(); root = null }
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <Consumer />
        </GameDataProvider>
      )
    })

    await new Promise(r => setTimeout(r, 200))

    const gd = (window as any).__gd
    expect(gd.data.quests[0].id).toBe(2)

    // dispatch invalid replace (missing id/title) to force server 400
    await act(async () => {
      gd.questsDispatch({ type: 'replace', payload: [ { notanid: true } ] })
    })

    // allow server roundtrip
    await new Promise(r => setTimeout(r, 800))

    // provider should have rolled back to previous snapshot
    expect((window as any).__gd.data.quests[0].id).toBe(2)

    // queue should contain the failed action
    const qraw = localStorage.getItem('everland_sync_queue')
    expect(qraw).not.toBeNull()
    const q = JSON.parse(qraw || '[]')
    expect(q.find((e:any) => e.op === 'action' && e.body && e.body.action && e.body.action.type === 'replace')).toBeTruthy()
  })
})
