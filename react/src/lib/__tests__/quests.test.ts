import { describe, it, expect } from 'vitest'
import { sampleQuests, canCompleteQuest, consumeRequirements } from '../quests'

describe('quests helpers', () => {
  it('canCompleteQuest detects completion', () => {
    const quests = sampleQuests()
    const q = quests[0]
    const inv = [{ itemId: q.requirements[0].itemId, qty: q.requirements[0].qty }]
    expect(canCompleteQuest(q, inv)).toBe(true)
  })

  it('consumeRequirements reduces inventory', () => {
    const quests = sampleQuests()
    const q = quests[1]
    const inv = [{ itemId: q.requirements[0].itemId, qty: q.requirements[0].qty + 1 }]
    const newInv = consumeRequirements(inv, q)
    expect(newInv).not.toBeNull()
    expect(newInv!.reduce((s, it) => s + it.qty, 0)).toBe(1)
  })
})
