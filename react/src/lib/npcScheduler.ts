import { useEffect, useRef } from 'react'
import loadNpcs from './npcs'
import { ensureRestock, popDialog, detectShopItemsFromNpc } from './npcService'

export function useNpcScheduler(npcState: Record<string, any>, setNpcState: (s: Record<string, any>) => void, addToast?: (m: string) => void, intervalMs = 5000) {
  const stateRef = useRef(npcState)
  useEffect(() => { stateRef.current = npcState }, [npcState])

  useEffect(() => {
    let mounted = true
    let npcs: any[] = []
    loadNpcs().then((n) => { if (mounted) npcs = n }).catch(() => {})
    const id = setInterval(() => {
      try {
        let cur = stateRef.current || {}
        // Restock using npc list
        for (const npc of npcs) {
          const lbl = npc && npc.label
          if (!lbl) continue
          const defaultItems = detectShopItemsFromNpc(npc)
          const r = ensureRestock(lbl, cur, intervalMs * 12, defaultItems, 5)
          if (r.restocked) {
            cur = r.nextState
            if (addToast) addToast(`${npc.name || lbl} restocked`)
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
        if (cur !== stateRef.current) setNpcState(cur)
      } catch (e) { /* noop */ }
    }, intervalMs)
    return () => { mounted = false; clearInterval(id) }
  }, [setNpcState, addToast, intervalMs])
}

export default useNpcScheduler
