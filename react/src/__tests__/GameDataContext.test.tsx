/**
 * @vitest-environment jsdom
 */
 
import React from 'react'
import ReactDOM from 'react-dom/client'
import { act } from 'react'
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { GameDataProvider, useGameData } from '../context/GameDataContext'

function TestConsumer() {
  const gd = useGameData()
  return (
    <div>
      <div data-testid="status">{gd.status}</div>
      <div data-testid="items">{JSON.stringify(gd.data?.items)}</div>
    </div>
  )
}

describe('GameDataProvider', () => {
  let root: ReactDOM.Root | null = null
  const container = document.createElement('div')
  document.body.appendChild(container)

  beforeEach(() => {
    // mock fetch responses
    (globalThis as any).fetch = (input: RequestInfo) => {
      const url = String(input)
      if (url.endsWith('/bbs/item_names.json')) {
        return Promise.resolve(new Response(JSON.stringify({ '24': 'Berry' }), { status: 200 }))
      }
      if (url.endsWith('/bbs/npcs.json')) return Promise.resolve(new Response(JSON.stringify([]), { status: 200 }))
      if (url.endsWith('/bbs/quests.json')) return Promise.resolve(new Response(JSON.stringify([]), { status: 200 }))
      if (url.endsWith('/bbs/recipes.json')) return Promise.resolve(new Response(JSON.stringify([]), { status: 200 }))
      return Promise.resolve(new Response('{}', { status: 200 }))
    }
  })

  afterEach(() => {
    if (root) { root.unmount(); root = null }
  })

  it('loads data and exposes items in context', async () => {
    await act(async () => {
      root = ReactDOM.createRoot(container)
      root.render(
        <GameDataProvider>
          <TestConsumer />
        </GameDataProvider>
      )
    })

    // wait for provider to update status to 'ready'
    const waitForReady = () => new Promise<void>((resolve, reject) => {
      const start = Date.now()
      const tick = () => {
        const statusEl = container.querySelector('[data-testid="status"]')
        if (statusEl && statusEl.textContent === 'ready') return resolve()
        if (Date.now() - start > 2000) return reject(new Error('timeout waiting for ready'))
        setTimeout(tick, 30)
      }
      tick()
    })

    await waitForReady()

    const itemsEl = container.querySelector('[data-testid="items"]')
    expect(itemsEl).not.toBeNull()
    expect(itemsEl!.textContent).toContain('Berry')
  })
})
