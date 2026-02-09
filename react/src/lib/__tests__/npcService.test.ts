import { describe, it, expect } from 'vitest'
import { enqueueDialog, popDialog, ensureRestock } from '../npcService'

describe('npcService dialog queue and restock', () => {
  it('enqueue and pop dialog works in FIFO order', () => {
    const label = 'testNpc'
    let state: Record<string, any> = {}
    state = enqueueDialog(label, state, 'hello')
    state = enqueueDialog(label, state, 'bye')

    const r1 = popDialog(label, state)
    expect(r1.text).toBe('hello')
    state = r1.nextState

    const r2 = popDialog(label, state)
    expect(r2.text).toBe('bye')
    state = r2.nextState

    const r3 = popDialog(label, state)
    expect(r3.text).toBeNull()
  })

  it('ensureRestock sets nextRestock and prevents immediate restock', () => {
    const label = 'testNpc2'
    const interval = 1000
    const r1 = ensureRestock(label, {}, interval)
    expect(r1.restocked).toBe(true)
    expect(r1.nextState[label]).toBeDefined()
    expect(typeof r1.nextState[label].nextRestock).toBe('number')

    const r2 = ensureRestock(label, r1.nextState, interval)
    expect(r2.restocked).toBe(false)
  })
})
import { describe, it, expect } from 'vitest'
import { talkToNpc } from '../npcService'
import { NPC } from '../npcs'

const mockNpcs: NPC[] = [
  {
    label: 'npc_joe',
    name: 'Joe',
    description: '',
    texts: ['Hello', 'Goodbye'],
    bytes: {},
    unnamedBytes: [],
    words: {},
    unnamedWords: [],
    comments: [],
    raw: ''
  }
]

describe('npcService.talkToNpc', () => {
  it('returns first line then advances dialogIndex', () => {
    let state: Record<string, any> = {}
    let res = talkToNpc('npc_joe', mockNpcs, state)
    expect(res.text).toBe('Hello')
    state = res.nextState
    res = talkToNpc('npc_joe', mockNpcs, state)
    expect(res.text).toBe('Goodbye')
    state = res.nextState
    res = talkToNpc('npc_joe', mockNpcs, state)
    expect(res.text).toBe('Hello')
  })
})
