import { describe, it, expect } from 'vitest'
import { ensureRestock } from '../npcService'

describe('ensureRestock respects defaultQty', () => {
  it('sets stock quantities to provided defaultQty for missing or empty slots', () => {
    const label = 'restock_npc'
    const defaultItems = [1,2,3]
    const r = ensureRestock(label, {}, 1000, defaultItems, 7)
    expect(r.restocked).toBe(true)
    const s = r.nextState[label]
    expect(s).toBeDefined()
    expect(s.stock).toBeDefined()
    expect(Number(s.stock['1'])).toBe(7)
    expect(Number(s.stock['2'])).toBe(7)
    expect(Number(s.stock['3'])).toBe(7)
  })

  it('does not overwrite positive existing stock values', () => {
    const label = 'restock_npc2'
    const state: Record<string, any> = { [label]: { stock: { '1': 2, '2': 0 } } }
    const defaultItems = [1,2,3]
    const r = ensureRestock(label, state, 1000, defaultItems, 9)
    const s = r.nextState[label]
    expect(Number(s.stock['1'])).toBe(2) // preserved
    expect(Number(s.stock['2'])).toBe(9) // was 0 -> replaced
    expect(Number(s.stock['3'])).toBe(9) // added
  })
})
