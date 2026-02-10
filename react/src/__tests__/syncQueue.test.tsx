/**
 * @vitest-environment jsdom
 */

import React from 'react'
import ReactDOM from 'react-dom/client'
import { act } from 'react'
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { GameDataProvider, useGameData } from '../context/GameDataContext'

function ExposeSync() {
  const gd = useGameData()
  ;(window as any).__sync = gd.syncToServer
  return <div />
}

describe('sync queue', () => {
  let root: ReactDOM.Root | null = null
  const container = document.createElement('div')
  document.body.appendChild(container)

  beforeEach(() => {
    localStorage.clear()
  })

  afterEach(() => {
    if (root) { root.unmount(); root = null }
    localStorage.clear()
    ;(window as any).__sync = undefined
  })

  it('enqueues on failed sync', async () => {
    // make fetch fail
    ;(globalThis as any).fetch = () => Promise.resolve(new Response('{}', { status: 500 }))

    await act(async () => {
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <ExposeSync />
        </GameDataProvider>
      )
    })

    // wait for provider ready
    await new Promise(r => setTimeout(r, 100))

    const sync = (window as any).__sync
    expect(typeof sync).toBe('function')

    let threw = false
    try {
      await act(async () => { await sync([{ id: 1 }]) })
    } catch (e) { threw = true }
    expect(threw).toBe(true)

    const qraw = localStorage.getItem('everland_sync_queue')
    expect(qraw).not.toBeNull()
    const q = JSON.parse(qraw || '[]')
    expect(Array.isArray(q)).toBe(true)
    expect(q.length).toBeGreaterThan(0)
  })

  it('processes queue when server recovers', async () => {
    let fail = true
    ;(globalThis as any).fetch = () => {
      if (fail) return Promise.resolve(new Response('{}', { status: 500 }))
      return Promise.resolve(new Response('{}', { status: 200 }))
    }

    await act(async () => {
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <ExposeSync />
        </GameDataProvider>
      )
    })

    await new Promise(r => setTimeout(r, 100))
    const sync = (window as any).__sync
    expect(typeof sync).toBe('function')

    // first attempt will enqueue
    await act(async () => {
      try { await sync([{ id: 2 }]) } catch (e) { }
    })

    let q = JSON.parse(localStorage.getItem('everland_sync_queue') || '[]')
    expect(q.length).toBeGreaterThan(0)

    // recover server
    fail = false

    // wait for background processor to run (interval 1s)
    await new Promise(r => setTimeout(r, 1500))

    q = JSON.parse(localStorage.getItem('everland_sync_queue') || '[]')
    expect(q.length).toBe(0)
  })
})
