import type { InventoryItem } from './crafting'

export type Quest = {
  id: number
  title: string
  description: string
  requirements: Array<{ itemId: number; qty: number }>
  reward: InventoryItem[]
  // state: 'available' | 'accepted' | 'in_progress' | 'completed'
  state: 'available' | 'accepted' | 'in_progress' | 'completed'
  completed: boolean
  prerequisites?: number[]
  // triggers: rules that respond to events
  triggers?: Array<{ type: string; key?: string; op?: string; value?: any; action?: 'accept'|'increment'|'complete'; incr?: number }>
  // optional numeric progress counter
  progress?: number
}

export function sampleQuests(): Quest[] {
  return [
    {
      id: 1,
      title: 'Gather Berries',
      description: 'Bring 5 berries to Kira.',
      requirements: [{ itemId: 24, qty: 5 }],
      reward: [{ itemId: 6, qty: 1 }],
      state: 'available',
      completed: false
    },
    {
      id: 2,
      title: 'Chop Wood',
      description: 'Deliver 8 wood logs to the carpenter.',
      requirements: [{ itemId: 21, qty: 8 }],
      reward: [{ itemId: 37, qty: 2 }],
      state: 'available',
      completed: false
    }
  ]
}

// Unlock quests whose prerequisites are satisfied
export function unlockQuests(quests: Quest[]) {
  const byId = new Map<number, Quest>()
  for (const q of quests) byId.set(q.id, q)
  // if a quest has prerequisites and all are completed, mark it accepted=false (available)
  const updated = quests.map(q => ({ ...q }))
  for (const q of updated) {
    if (Array.isArray(q.prerequisites) && q.prerequisites.length > 0) {
      const allDone = q.prerequisites.every(pid => byId.get(pid)?.completed)
      if (allDone && !q.completed) {
        // ensure state is available
        if (q.state !== 'completed') q.state = 'available'
      }
    }
  }
  return updated
}

function evalCondition(event: any, trig: any) {
  if (!trig || !trig.type) return false
  if (trig.type !== event.type) return false
  if (!trig.key) return true
  const left = event[trig.key]
  const right = trig.value
  const op = trig.op || '=='
  switch (op) {
    case '==': return left == right
    case '===': return left === right
    case '!=': return left != right
    case '>=': return left >= right
    case '<=': return left <= right
    case '>': return left > right
    case '<': return left < right
    case 'contains': return Array.isArray(left) ? left.includes(right) : String(left).includes(String(right))
    default: return false
  }
}

export function processEventTrigger(event: any, quests: Quest[]) {
  if (!event || !event.type) return { quests, accepted: [] }
  const updated = quests.map(q => ({ ...q }))
  const accepted: number[] = []
  const byId = new Map<number, Quest>()
  for (const q of updated) byId.set(q.id, q)

  for (const q of updated) {
    if (q.completed) continue
    if (!Array.isArray(q.triggers) || q.triggers.length === 0) continue
    for (const t of q.triggers) {
      if (!evalCondition(event, t)) continue
      // perform action
      if (t.action === 'accept') {
        if (q.state === 'available') { q.state = 'accepted'; accepted.push(q.id) }
      } else if (t.action === 'increment') {
        q.progress = (q.progress || 0) + (typeof t.incr === 'number' ? t.incr : 1)
        if (q.progress && q.requirements && q.requirements.length === 0) q.state = 'in_progress'
      } else if (t.action === 'complete') {
        q.state = 'completed'
        q.completed = true
      } else {
        // default: accept
        if (q.state === 'available') { q.state = 'accepted'; accepted.push(q.id) }
      }
    }
  }

  return { quests: updated, accepted }
}

// Accept a quest by id
export function acceptQuestById(quests: Quest[], id: number) {
  return quests.map(q => q.id === id ? { ...q, accepted: true } : q)
}

export function canCompleteQuest(q: Quest, inventory: InventoryItem[]) {
  for (const req of q.requirements) {
    const have = inventory.reduce((s, it) => (it.itemId === req.itemId ? s + it.qty : s), 0)
    if (have < req.qty) return false
  }
  return true
}

export function consumeRequirements(inv: InventoryItem[], q: Quest): InventoryItem[] | null {
  let working = inv.map(i => ({ ...i }))
  for (const req of q.requirements) {
    let need = req.qty
    for (const slot of working) {
      if (slot.itemId !== req.itemId) continue
      const take = Math.min(slot.qty, need)
      slot.qty -= take
      need -= take
      if (need <= 0) break
    }
    if (need > 0) return null
    working = working.filter(s => s.qty > 0)
  }
  return working
}

export function completeAvailableQuests(quests: Quest[], inventory: InventoryItem[]) {
  let inv = inventory.map(i => ({ ...i }))
  const updatedQuests = quests.map(q => ({ ...q }))
  const completed: number[] = []

  for (const q of updatedQuests) {
    if (!q.accepted || q.completed) continue
    if (canCompleteQuest(q, inv)) {
      const after = consumeRequirements(inv, q)
      if (after) {
        inv = after
        // apply rewards
        for (const r of q.reward) {
          const s = inv.find(x => x.itemId === r.itemId)
          if (s) s.qty += r.qty
          else inv.push({ itemId: r.itemId, qty: r.qty })
        }
        q.completed = true
        completed.push(q.id)
      }
    }
  }

  // normalize inventory
  inv = inv.filter(i => i.qty > 0)
  return { quests: updatedQuests, inventory: inv, completed }
}
