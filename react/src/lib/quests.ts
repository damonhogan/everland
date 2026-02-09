import type { InventoryItem } from './crafting'

export type Quest = {
  id: number
  title: string
  description: string
  requirements: Array<{ itemId: number; qty: number }>
  reward: InventoryItem[]
  accepted: boolean
  completed: boolean
  prerequisites?: number[]
  triggers?: Array<{ type: string; key?: string; value?: any }>
}

export function sampleQuests(): Quest[] {
  return [
    {
      id: 1,
      title: 'Gather Berries',
      description: 'Bring 5 berries to Kira.',
      requirements: [{ itemId: 24, qty: 5 }],
      reward: [{ itemId: 6, qty: 1 }],
      accepted: false,
      completed: false
    },
    {
      id: 2,
      title: 'Chop Wood',
      description: 'Deliver 8 wood logs to the carpenter.',
      requirements: [{ itemId: 21, qty: 8 }],
      reward: [{ itemId: 37, qty: 2 }],
      accepted: false,
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
        // leave accepted as-is; it's available to accept
      }
    }
  }
  return updated
}

// Accept a quest by id
export function acceptQuestById(quests: Quest[], id: number) {
  return quests.map(q => q.id === id ? { ...q, accepted: true } : q)
}

// Process a single game event and accept quests whose triggers match the event
export function processEventTrigger(event: any, quests: Quest[]): { quests: Quest[]; accepted: number[] } {
  if (!event || !event.type) return { quests, accepted: [] }
  const accepted: number[] = []
  const updated = quests.map(q => ({ ...q }))
  const byId = new Map<number, Quest>()
  for (const qq of updated) byId.set(qq.id, qq)

  for (const q of updated) {
    if (q.completed || q.accepted) continue
    if (!Array.isArray(q.triggers) || q.triggers.length === 0) continue
    for (const t of q.triggers) {
      if (t.type !== event.type) continue
      // basic payload match: if key present, compare event[key] === value
      if (t.key && typeof t.value !== 'undefined') {
        if ((event as any)[t.key] === t.value) {
          // ensure prerequisites satisfied
          const allDone = Array.isArray(q.prerequisites) ? q.prerequisites.every(pid => byId.get(pid)?.completed) : true
          if (allDone) { q.accepted = true; accepted.push(q.id); }
        }
      } else {
        const allDone = Array.isArray(q.prerequisites) ? q.prerequisites.every(pid => byId.get(pid)?.completed) : true
        if (allDone) { q.accepted = true; accepted.push(q.id); }
      }
    }
  }

  return { quests: updated, accepted }
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
