import { useEffect, useRef } from 'react'
import loadNpcs from './npcs'
import { ensureRestock, popDialog, detectShopItemsFromNpc, advancePatrol, popDueDialogs } from './npcService'

// determine restock default quantity priority:
// 1. runtime edited value: npcState[label].edited.restockDefaultQty
// 2. generator value: npc.restockDefaultQty
// 3. fallback value
export function computeRestockQty(npc: any, curStateEntry: any, fallback = 5) {
  try {
    if (curStateEntry && curStateEntry.edited && typeof curStateEntry.edited.restockDefaultQty === 'number') return Number(curStateEntry.edited.restockDefaultQty)
    if (npc && typeof npc.restockDefaultQty === 'number') return Number(npc.restockDefaultQty)
  } catch (e) {}
  return fallback
}

// perform a single scheduler tick for the provided NPC list and current state; returns nextState
export function runNpcSchedulerTick(npcs: any[], curState: Record<string, any>, addToast?: (m: string) => void, intervalMs = 5000) {
  let cur = { ...(curState || {}) }
  for (const npc of npcs) {
    const lbl = npc && npc.label
    if (!lbl) continue
    const defaultItems = detectShopItemsFromNpc(npc)
    const restInterval = (cur && cur[lbl] && cur[lbl].edited && cur[lbl].edited.restockInterval) ? Number(cur[lbl].edited.restockInterval) : intervalMs * 12
    const curEntry = (cur && cur[lbl]) ? cur[lbl] : {}
    const defaultQty = computeRestockQty(npc, curEntry, 5)
    const r = ensureRestock(lbl, cur, restInterval, defaultItems, defaultQty)
    if (r.restocked) { cur = r.nextState; if (addToast) addToast(`${npc.name || lbl} restocked`) }

    // patrol advance
    const patrolRes = advancePatrol(lbl, cur, (cur && cur[lbl] && cur[lbl].edited && cur[lbl].edited.patrolInterval) ? Number(cur[lbl].edited.patrolInterval) : 30000)
    if (patrolRes.moved) {
      cur = patrolRes.nextState
      if (addToast) addToast(`${npc.name || lbl} moved to ${patrolRes.location}`)
    }

    // scheduled dialogs
    const popped = popDueDialogs(lbl, cur)
    if (popped.texts && popped.texts.length > 0) {
      cur = popped.nextState
      for (const t of popped.texts) if (addToast) addToast(t)
    }
  }

  // pop one queued dialog if present
  for (const lbl of Object.keys(cur || {})) {
    const popped = popDialog(lbl, cur)
    if (popped.text) {
      cur = popped.nextState
      if (addToast) addToast(popped.text)
      break
    }
  }
  return cur
}

export function useNpcScheduler(npcState: Record<string, any>, setNpcState: (s: Record<string, any>) => void, addToast?: (m: string) => void, intervalMs = 5000) {
  const stateRef = useRef(npcState)
  useEffect(() => { stateRef.current = npcState }, [npcState])

  useEffect(() => {
    let mounted = true
    let npcs: any[] = []
    loadNpcs().then((n) => { if (mounted) npcs = n }).catch(() => {})
    const id = setInterval(() => {
      try {
        const next = runNpcSchedulerTick(npcs, stateRef.current || {}, addToast, intervalMs)
        if (next !== stateRef.current) setNpcState(next)
      } catch (e) { /* noop */ }
    }, intervalMs)
    return () => { mounted = false; clearInterval(id) }
  }, [setNpcState, addToast, intervalMs])
}

export default useNpcScheduler
