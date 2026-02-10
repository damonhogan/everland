/**
 * @vitest-environment jsdom
 */

import React from 'react'
import ReactDOM from 'react-dom/client'
import { act } from 'react'
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { GameDataProvider, useGameData } from '../context/GameDataContext'
import QuestPanel from '../components/QuestPanel'

function SimpleConsumer() {
  const gd = useGameData()
  // expose dispatch and quests for tests
  ;(window as any).__testDispatch = gd.questsDispatch
  return <div data-testid="quests">{JSON.stringify(gd.data?.quests)}</div>
}

describe('quests reducer and import flow', () => {
  let root: ReactDOM.Root | null = null
  const container = document.createElement('div')
  document.body.appendChild(container)

  beforeEach(() => {
    ;(globalThis as any).fetch = (input: RequestInfo) => {
      const url = String(input)
      if (url.endsWith('/bbs/item_names.json')) {
        return Promise.resolve(new Response(JSON.stringify({ '24': 'Berry' }), { status: 200 }))
      }
      if (url.endsWith('/bbs/npcs.json')) return Promise.resolve(new Response(JSON.stringify([]), { status: 200 }))
      if (url.endsWith('/bbs/quests.json')) return Promise.resolve(new Response(JSON.stringify([]), { status: 200 }))
      if (url.endsWith('/bbs/recipes.json')) return Promise.resolve(new Response(JSON.stringify([]), { status: 200 }))
      return Promise.resolve(new Response('{}', { status: 200 }))
    }
    localStorage.clear()
  })

  afterEach(() => {
    if (root) { root.unmount(); root = null }
    localStorage.clear()
    ;(window as any).__testDispatch = undefined
  })

  it('updates quests via questsDispatch and persists to localStorage', async () => {
    await act(async () => {
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <SimpleConsumer />
        </GameDataProvider>
      )
    })

    // wait for provider ready
    const waitForReady = () => new Promise<void>((resolve, reject) => {
      const start = Date.now()
      const tick = () => {
        const el = container.querySelector('[data-testid="quests"]')
        if (el && el.textContent !== 'undefined') return resolve()
        if (Date.now() - start > 2000) return reject(new Error('timeout'))
        setTimeout(tick, 30)
      }
      tick()
    })

    await waitForReady()

    // call dispatch
    const dispatch = (window as any).__testDispatch
    expect(typeof dispatch).toBe('function')
    act(() => { dispatch({ type: 'replace', payload: [{ id: 42, title: 'Imported', description: '', requirements: [], reward: [], state: 'in_progress' }] }) })

    // allow state propagation
    await new Promise(r => setTimeout(r, 50))

    const persisted = JSON.parse(localStorage.getItem('everland_game_data') || '{}')
    expect(persisted.data).toBeDefined()
    expect(Array.isArray(persisted.data.quests)).toBe(true)
    expect(persisted.data.quests[0].id).toBe(42)
  })

  it('imports quests via dispatch (simulated import)', async () => {
    await act(async () => {
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <QuestPanel inventory={[]} setInventory={() => {}} addToast={() => {}} />
          <SimpleConsumer />
        </GameDataProvider>
      )
    })

    // wait for provider ready
    const waitForReady = () => new Promise<void>((resolve, reject) => {
      const start = Date.now()
      const tick = () => {
        const el = container.querySelector('[data-testid="quests"]')
        if (el && el.textContent !== 'undefined') return resolve()
        if (Date.now() - start > 2000) return reject(new Error('timeout'))
        setTimeout(tick, 30)
      }
      tick()
    })

    await waitForReady()

    const dispatch = (window as any).__testDispatch
    expect(typeof dispatch).toBe('function')
    act(() => { dispatch({ type: 'replace', payload: [{ id: 99, title: 'FromFile', description: '', requirements: [], reward: [], state: 'in_progress' }] }) })

    // allow state propagation
    await new Promise(r => setTimeout(r, 100))

    const persisted = JSON.parse(localStorage.getItem('everland_game_data') || '{}')
    expect(persisted.data).toBeDefined()
    expect(Array.isArray(persisted.data.quests)).toBe(true)
    expect(persisted.data.quests[0].id).toBe(99)
  })
})
