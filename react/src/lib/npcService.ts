import { NPC, loadNpcs } from './npcs'

// Compute price for an item considering global shop prices and npcState overrides
export function getPriceForItem(itemId: number, shopPrices: Record<string, number>, npcStateForLabel?: any): number {
  // npcStateForLabel may contain edited.prices map
  if (npcStateForLabel && npcStateForLabel.edited && npcStateForLabel.edited.prices && npcStateForLabel.edited.prices[String(itemId)] != null) {
    return Number(npcStateForLabel.edited.prices[String(itemId)])
  }
  if (shopPrices && shopPrices[String(itemId)] != null) return Number(shopPrices[String(itemId)])
  return 10
}

// Detect shop items from NPC definition (same heuristic as NPCPanel)
export function detectShopItemsFromNpc(npc: NPC): number[] {
  const ids: number[] = []
  for (const k of Object.keys((npc as any).bytes || {})) {
    const arr = (npc as any).bytes[k]
    if (Array.isArray(arr)) arr.forEach((v: any) => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) })
  }
  if (Array.isArray((npc as any).unnamedBytes)) {
    ;(npc as any).unnamedBytes.forEach((arr: any) => arr.forEach((v: any) => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) }))
  }
  for (const k of Object.keys((npc as any).words || {})) {
    const arr = (npc as any).words[k]
    if (Array.isArray(arr)) arr.forEach((v: any) => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) })
  }
  if (Array.isArray((npc as any).unnamedWords)) {
    ;(npc as any).unnamedWords.forEach((arr: any) => arr.forEach((v: any) => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) }))
  }
  return Array.from(new Set(ids))
}

// Patrols / schedules helpers
export function setPatrol(label: string, npcState: Record<string, any>, points: string[]) {
  const cur = npcState[label] || {}
  const next = { ...npcState, [label]: { ...cur, patrol: points, patrolIndex: 0, nextPatrolAt: Date.now() + 1000 } }
  return next
}

export function advancePatrol(label: string, npcState: Record<string, any>, intervalMs = 1000 * 30) {
  const cur = npcState[label] || {}
  const pts: string[] = Array.isArray(cur.patrol) ? cur.patrol : []
  if (pts.length === 0) return { moved: false, nextState: npcState }
  const idx = typeof cur.patrolIndex === 'number' ? cur.patrolIndex : 0
  const nextIdx = (idx + 1) % pts.length
  const next = { ...npcState, [label]: { ...cur, patrolIndex: nextIdx, nextPatrolAt: Date.now() + intervalMs } }
  return { moved: true, nextState: next, location: pts[nextIdx] }
}

export function scheduleDialog(label: string, npcState: Record<string, any>, whenMs: number, text: string) {
  const cur = npcState[label] || {}
  const list = Array.isArray(cur.scheduledDialogs) ? [...cur.scheduledDialogs] : []
  list.push({ at: Date.now() + whenMs, text })
  const next = { ...npcState, [label]: { ...cur, scheduledDialogs: list } }
  return next
}

export function popDueDialogs(label: string, npcState: Record<string, any>) {
  const cur = npcState[label] || {}
  const list = Array.isArray(cur.scheduledDialogs) ? [...cur.scheduledDialogs] : []
  const now = Date.now()
  const due = list.filter((d:any) => d.at <= now)
  const remaining = list.filter((d:any) => d.at > now)
  const next = { ...npcState, [label]: { ...cur, scheduledDialogs: remaining } }
  return { texts: due.map((d:any)=>d.text), nextState: next }
}

// Buy/Sell helpers that return updated gold/inventory and npcState
export function buyItem(label: string, itemId: number, price: number, gold: number | null | undefined, inventory: any[], setNpcState: (s: Record<string, any>) => void, npcState: Record<string, any>) {
  if (gold == null || gold < price) return { ok: false, message: 'Not enough gold', gold, inventory, npcState }
  const cur = npcState[label] || {}
  const stock = (cur.stock && typeof cur.stock === 'object') ? { ...cur.stock } : null
  if (stock) {
    const have = Number(stock[String(itemId)] || 0)
    if (have <= 0) return { ok: false, message: 'Out of stock', gold, inventory, npcState }
    stock[String(itemId)] = Math.max(0, have - 1)
  }
  const nextGold = gold - price
  const inv = inventory ? inventory.map((x: any) => ({ ...x })) : []
  const found = inv.find((x: any) => x.itemId === itemId)
  if (found) found.qty += 1; else inv.push({ itemId, qty: 1 })
  // update npcState to record last purchase and trigger near-term restock
  const nextNpcState = { ...npcState, [label]: { ...cur, lastBoughtAt: Date.now(), nextRestock: 0, ...(stock ? { stock } : {}) } }
  return { ok: true, message: 'Bought', gold: nextGold, inventory: inv, npcState: nextNpcState }
}

export function sellItem(label: string, itemId: number, price: number, gold: number | null | undefined, inventory: any[], setNpcState: (s: Record<string, any>) => void, npcState: Record<string, any>) {
  const inv = inventory ? inventory.map((x: any) => ({ ...x })) : []
  const found = inv.find((x: any) => x.itemId === itemId)
  if (!found || found.qty <= 0) return { ok: false, message: 'You have none to sell', gold, inventory, npcState }
  const sellPrice = Math.max(1, Math.floor(price / 2))
  const nextGold = (gold || 0) + sellPrice
  const nextInv = inv.map((x: any) => x.itemId === itemId ? { ...x, qty: x.qty - 1 } : x).filter((x: any) => x.qty > 0)
  // optionally increase NPC stock when selling to them
  const cur = npcState[label] || {}
  const stock = (cur.stock && typeof cur.stock === 'object') ? { ...cur.stock } : {}
  stock[String(itemId)] = (Number(stock[String(itemId)] || 0) + 1)
  const nextNpcState = { ...npcState, [label]: { ...cur, stock } }
  return { ok: true, message: 'Sold', gold: nextGold, inventory: nextInv, npcState: nextNpcState }
}

// NPC scheduling + dialog queue + restock
export function enqueueDialog(label: string, npcState: Record<string, any>, text: string) {
  const cur = npcState[label] || {}
  const queue = Array.isArray(cur.dialogQueue) ? [...cur.dialogQueue] : []
  queue.push(text)
  const next = { ...npcState, [label]: { ...cur, dialogQueue: queue } }
  return next
}

export function popDialog(label: string, npcState: Record<string, any>) {
  const cur = npcState[label] || {}
  const queue = Array.isArray(cur.dialogQueue) ? [...cur.dialogQueue] : []
  const text = queue.shift() || null
  const next = { ...npcState }
  next[label] = { ...cur, dialogQueue: queue }
  return { text, nextState: next }
}

export function ensureRestock(label: string, npcState: Record<string, any>, intervalMs = 1000 * 60 * 60, defaultItems?: number[], defaultQty = 5) {
  // restock logic: if nextRestock <= now, set nextRestock = now + interval and set stock for defaultItems
  const cur = npcState[label] || {}
  const now = Date.now()
  const nextRestock = typeof cur.nextRestock === 'number' ? cur.nextRestock : 0
  if (nextRestock <= now) {
    const stock = { ...(cur.stock || {}) }
    if (Array.isArray(defaultItems)) {
      for (const id of defaultItems) {
        const sid = String(id)
        if (!stock[sid] || stock[sid] <= 0) stock[sid] = defaultQty
      }
    }
    const next = { ...npcState, [label]: { ...cur, nextRestock: now + intervalMs, restockedAt: now, stock } }
    return { restocked: true, nextState: next }
  }
  return { restocked: false, nextState: npcState }
}

export async function getNpcs(): Promise<NPC[]> {
  return loadNpcs()
}

export function getNpcByLabel(npcs: NPC[], label: string): NPC | undefined {
  return npcs.find(n => n.label === label)
}

// Talk to an NPC: return the chosen text and the updated npcState with incremented dialogIndex
export function talkToNpc(label: string, npcs: NPC[], npcState: Record<string, any>): { text: string | null, nextState: Record<string, any> } {
  const npc = getNpcByLabel(npcs, label)
  if (!npc) return { text: null, nextState: npcState }

  const texts = (npc.texts && npc.texts.length) ? npc.texts : (npc.description ? npc.description.split('\n').filter(Boolean) : [])
  const cur = npcState[label] || {}
  const idx = (typeof cur.dialogIndex === 'number') ? cur.dialogIndex : 0
  const text = texts.length ? (texts[idx] ?? texts[0]) : null
  const nextIdx = texts.length ? ((idx + 1) % texts.length) : 0
  const nextState = { ...npcState, [label]: { ...cur, dialogIndex: nextIdx } }
  return { text, nextState }
}

export default { getNpcs, getNpcByLabel, talkToNpc }
