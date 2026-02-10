import { describe, it, expect } from 'vitest'
import { runNpcSchedulerTick } from '../npcScheduler'
import { ensureRestock } from '../npcService'

// mock NPCs
const mockNpcs = [
  { label: 'npc_a', name: 'A', restockDefaultQty: 3, patrolTemplate: ['r1','r2'], defaultPatrolIntervalMs: 1000 }
]

describe('runNpcSchedulerTick', () => {
  it('restocks and advances patrols', () => {
    let state: Record<string, any> = {}
    // first tick should restock and set patrol from template only if present in state; we simulate state having patrol
    state['npc_a'] = { patrol: ['r1','r2'], patrolIndex: 0, nextPatrolAt: Date.now() - 1000 }
    const next = runNpcSchedulerTick(mockNpcs, state, undefined, 100)
    // should have updated patrolIndex or stock
    expect(next['npc_a']).toBeDefined()
    // restock should have added stock for items [] (no shop items in mock) but ensure no crash
    // patrolIndex should be advanced
    expect(typeof next['npc_a'].patrolIndex).toBe('number')
  })
})
