import { describe, it, expect } from 'vitest'
import { computeRestockQty } from '../npcScheduler'

describe('computeRestockQty priority', () => {
  it('prefers npcState edited override when present', () => {
    const npc = { restockDefaultQty: 4 }
    const curEntry = { edited: { restockDefaultQty: 9 } }
    expect(computeRestockQty(npc, curEntry, 5)).toBe(9)
  })

  it('falls back to generator restockDefaultQty when edited not present', () => {
    const npc = { restockDefaultQty: 6 }
    const curEntry = { }
    expect(computeRestockQty(npc, curEntry, 5)).toBe(6)
  })

  it('uses fallback when neither present', () => {
    const npc = { }
    const curEntry = { }
    expect(computeRestockQty(npc, curEntry, 7)).toBe(7)
  })
})
