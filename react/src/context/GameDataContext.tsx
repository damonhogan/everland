import React, { createContext, useContext, useEffect, useState } from 'react';
import type { GameData, GameDataState } from '../types/game';

const defaultState: GameDataState = { status: 'idle' };

const CACHE_KEY = 'everland_game_data'
const QUEUE_KEY = 'everland_sync_queue'
const CACHE_TTL_MS = 1000 * 60 * 5 // 5 minutes

// API base can be provided by tests or environment to make absolute URLs available.
const API_BASE: string = (() => {
  try {
    if (typeof window !== 'undefined' && (window as any).__API_BASE__) return (window as any).__API_BASE__
    if (typeof process !== 'undefined' && process.env && (process.env.API_BASE || (process.env as any).VITE_API_BASE)) return (process.env.API_BASE || (process.env as any).VITE_API_BASE) as string
    if (typeof import.meta !== 'undefined' && (import.meta as any).env && (import.meta as any).env.VITE_API_BASE) return (import.meta as any).env.VITE_API_BASE
  } catch (_) {}
  return ''
})()

function buildUrl(path: string) {
  if (!path) return path
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (API_BASE && path.startsWith('/')) return API_BASE.replace(/\/$/, '') + path
  return path
}

const GameDataContext = createContext<GameDataState>(defaultState);

export const GameDataProvider: React.FC<{ children?: React.ReactNode }> = ({ children }) => {
  const [state, setState] = useState<GameDataState>({ status: 'loading' });
  const [queueLen, setQueueLen] = useState<number>(() => loadQueue().length)

  // sync queue helpers
  type QueueEntry = { id: string; op: 'quests' | 'action'; body: any; retryCount: number; nextAttempt: number; ts: number }
  const [pendingActions, setPendingActions] = useState<Array<{ actionId: string; type: string; payload?: any; prevSnapshot?: any[] }>>([])

  function loadQueue(): QueueEntry[] {
    try {
      const raw = localStorage.getItem(QUEUE_KEY)
      if (!raw) return []
      return JSON.parse(raw) as QueueEntry[]
    } catch (e) { return [] }
  }

  function saveQueue(q: QueueEntry[]) {
    try { localStorage.setItem(QUEUE_KEY, JSON.stringify(q)) } catch (e) { }
    try { setQueueLen(q.length) } catch (_) { }
  }

  function enqueueSync(body: any, op: 'quests' | 'action' = 'quests') {
    const q = loadQueue()
    q.push({ id: String(Date.now()) + '-' + Math.random().toString(36).slice(2), op, body, retryCount: 0, nextAttempt: Date.now() + 300, ts: Date.now() })
    saveQueue(q)
  }

  function undoAction(actionId: string) {
    // remove pendingActions entry and rollback any optimistic change captured in prevSnapshot
    const entry = pendingActions.find(a => a.actionId === actionId)
    if (!entry) return
    // rollback to snapshot if present
    if (entry.prevSnapshot) {
      setState(prev => ({ ...prev, data: { ...(prev.data || {}), quests: entry.prevSnapshot } }))
      try { localStorage.setItem(CACHE_KEY, JSON.stringify({ ts: Date.now(), data: { ...(state.data || {}), quests: entry.prevSnapshot } })) } catch (_) { }
    }
    // remove queued actions with this actionId
    const q = loadQueue().filter(e => !(e.op === 'action' && e.body && e.body.action && e.body.action.actionId === actionId))
    saveQueue(q)
    setPendingActions(pa => pa.filter(a => a.actionId !== actionId))
  }

  async function tryPostOnce(url: string, body: any) {
    const full = buildUrl(url)
    const res = await fetch(full, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    if (!res.ok) throw new Error('Status ' + res.status)
    return res
  }

  // background processor
  useEffect(() => {
    let mounted = true
    const tick = async () => {
      if (!mounted) return
      const q = loadQueue()
      const now = Date.now()
      let changed = false
      for (let i = 0; i < q.length; i++) {
        const entry = q[i]
        if (entry.nextAttempt > now) continue
        try {
            const url = entry.op === 'action' ? '/api/quests/actions' : '/api/quests'
            await tryPostOnce(url, entry.body)
          // remove entry
          q.splice(i, 1)
          i--
          changed = true
        } catch (e) {
          entry.retryCount = (entry.retryCount || 0) + 1
          const delay = 300 * Math.pow(2, entry.retryCount)
          entry.nextAttempt = Date.now() + delay
          changed = true
        }
      }
      if (changed) saveQueue(q)
    }
    const id = setInterval(tick, 1000)
    return () => { mounted = false; clearInterval(id) }
  }, [])

  // quests reducer for advanced operations
  function questsReducer(current: any[], action: { type: string; payload?: any }) {
    switch (action.type) {
      case 'set_all':
        return Array.isArray(action.payload) ? action.payload : current
      case 'accept': {
        const id = action.payload?.id
        return current.map(q => q.id === id ? { ...q, state: 'accepted' } : q)
      }
      case 'complete': {
        const id = action.payload?.id
        return current.map(q => q.id === id ? { ...q, completed: true, state: 'completed' } : q)
      }
      case 'add_trigger': {
        const { id, trigger } = action.payload || {}
        return current.map(q => q.id === id ? { ...q, triggers: [ ...(q.triggers||[]), trigger ] } : q)
      }
      case 'clear_triggers': {
        const id = action.payload?.id
        return current.map(q => q.id === id ? { ...q, triggers: [] } : q)
      }
      case 'update_prereqs': {
        const { id, prerequisites } = action.payload || {}
        return current.map(q => q.id === id ? { ...q, prerequisites } : q)
      }
      case 'increment': {
        const { id, by } = action.payload || {}
        return current.map(q => q.id === id ? { ...q, progress: (q.progress||0) + (typeof by === 'number' ? by : 1) } : q)
      }
      case 'replace':
        return Array.isArray(action.payload) ? action.payload : current
      default:
        return current
    }
  }

  function makeDispatch() {
    return (action: { type: string; payload?: any; actionId?: string }) => {
      const actionId = action.actionId || ('client-' + Date.now() + '-' + Math.random().toString(36).slice(2))
      const actionWithId = { ...action, actionId }

      // optimistic update and register pending action with snapshot
      setState(prev => {
        const curQuests = (prev.data && Array.isArray(prev.data.quests)) ? prev.data!.quests : []
        const prevSnapshot = Array.isArray(curQuests) ? JSON.parse(JSON.stringify(curQuests)) : []
        const nextQuests = questsReducer(curQuests, actionWithId)
        const next = { ...prev, data: { ...(prev.data || {}), quests: nextQuests } }
        try { localStorage.setItem(CACHE_KEY, JSON.stringify({ ts: Date.now(), data: next.data })) } catch (e) { }
        // register pending action with snapshot for undo/rollback
        setPendingActions(pa => ([...pa, { actionId, type: action.type, payload: action.payload, prevSnapshot }]))

        // fire off server confirm (async, don't block render)
        ;(async () => {
          try {
            const resp = await fetch(buildUrl('/api/quests/actions'), { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action: actionWithId }) })
            if (resp.ok) {
              const parsed = await resp.json()
              if (parsed && parsed.quests) {
                setState(prev2 => ({ ...prev2, data: { ...(prev2.data || {}), quests: parsed.quests } }))
              }
            } else {
              // rollback to previous snapshot on server rejection
              setState(prev2 => ({ ...prev2, data: { ...(prev2.data || {}), quests: prevSnapshot } }))
              // enqueue action for retry
              enqueueSync({ action: actionWithId }, 'action')
            }
          } catch (e) {
            // network error -> rollback and enqueue
            setState(prev2 => ({ ...prev2, data: { ...(prev2.data || {}), quests: prevSnapshot } }))
            enqueueSync({ action: actionWithId }, 'action')
          } finally {
            setPendingActions(pa => pa.filter(a => a.actionId !== actionId))
          }
        })()

        return next
      })
    }
  }

  useEffect(() => {
    let mounted = true;

    async function loadAll(bypassCache = false) {
      try {
        // try cache first
        try {
          if (!bypassCache) {
            const raw = localStorage.getItem(CACHE_KEY)
            if (raw) {
              const parsed = JSON.parse(raw)
              if (parsed && parsed.ts && (Date.now() - parsed.ts) < CACHE_TTL_MS && parsed.data) {
                const dispatch = makeDispatch()
                const setQuestsFn = (q: any[]) => dispatch({ type: 'replace', payload: q })
                const syncToServer = async (body: any) => { try { await tryPostOnce(body) } catch (e) { enqueueSync(body); throw e } }
                setState({ status: 'ready', data: parsed.data, refresh: async () => loadAll(true), setQuests: setQuestsFn, questsDispatch: dispatch, syncToServer })
                return
              }
            }
          }
        } catch (e) {
          // ignore cache errors
        }

        const [itemsRes, npcsRes, questsRes, recipesRes] = await Promise.all([
          fetch(buildUrl('/bbs/item_names.json')),
          fetch(buildUrl('/bbs/npcs.json')),
          fetch(buildUrl('/bbs/quests.json')),
          fetch(buildUrl('/bbs/recipes.json')),
        ]);

        const [items, npcs, quests, recipes] = await Promise.all([
          itemsRes.ok ? itemsRes.json() : Promise.resolve({}),
          npcsRes.ok ? npcsRes.json() : Promise.resolve([]),
          questsRes.ok ? questsRes.json() : Promise.resolve([]),
          recipesRes.ok ? recipesRes.json() : Promise.resolve([]),
        ]);

        if (!mounted) return;

        const data: GameData = {
          items,
          npcs,
          quests,
          recipes,
        };

        // store cache
        try { localStorage.setItem(CACHE_KEY, JSON.stringify({ ts: Date.now(), data })) } catch (e) { /* ignore */ }

        const dispatch = makeDispatch()
        const setQuestsFn = (q: any[]) => dispatch({ type: 'replace', payload: q })

        // attach refresh, setQuests and questsDispatch
        const syncToServer = async (body: any) => { try { await tryPostOnce(body) } catch (e) { enqueueSync(body); throw e } }
        setState({ status: 'ready', data, refresh: async () => loadAll(true), setQuests: setQuestsFn, questsDispatch: dispatch, syncToServer });
      } catch (e: any) {
        // try to serve stale cache if available
        try {
          const raw = localStorage.getItem(CACHE_KEY)
          if (raw) {
            const parsed = JSON.parse(raw)
            if (parsed && parsed.data) {
              const dispatch = makeDispatch()
              const setQuestsFn = (q: any[]) => dispatch({ type: 'replace', payload: q })
                setState({ status: 'error', error: String(e), data: parsed.data, setQuests: setQuestsFn, refresh: async () => loadAll(true), questsDispatch: dispatch, syncToServer });
              return
            }
          }
        } catch (_) {
          // ignored
        }
          const syncToServer = async (body: any) => { try { await tryPostOnce(body) } catch (er) { enqueueSync(body); throw er } }
          setState({ status: 'error', error: String(e), refresh: async () => loadAll(true), setQuests: undefined, syncToServer });
      }
    }

    loadAll();
    return () => { mounted = false; };
  }, []);

  // keyboard shortcut: Alt+R to refresh game data (avoids overriding Ctrl/Cmd+R)
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'R' && e.altKey) {
        const active = document.activeElement as HTMLElement | null
        const tag = active && active.tagName ? active.tagName.toUpperCase() : ''
        const isInput = tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || (active && active.getAttribute && active.getAttribute('contenteditable') === 'true')
        if (isInput) return
        if (state && state.refresh) state.refresh()
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [state])

  // simple inline UI for loading/error so root app shows status without every component implementing it
  const providerValue = { ...state, pendingSyncs: queueLen, pendingActions, undoAction }
  return (
    <GameDataContext.Provider value={providerValue}>
      <div>
        {state.status === 'loading' ? (
          <div style={{padding:8, background:'#fffbe6', borderBottom:'1px solid #f0e68c', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
            <div>Loading game data…</div>
            <div style={{fontSize:12,color:'#666'}}>Source: remote</div>
          </div>
        ) : state.status === 'error' ? (
          <div style={{padding:8, background:'#ffecec', borderBottom:'1px solid #f5c6cb', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
            <div style={{display:'flex', alignItems:'center', gap:12}}>
              <div>Error loading game data: {state.error}</div>
                <div style={{fontSize:12, color:'#444'}}>Pending syncs: {queueLen}</div>
            </div>
            <div>
              <button className="button" style={{marginLeft:8}} onClick={() => { state.refresh && state.refresh() }}>Refresh</button>
            </div>
          </div>
        ) : (
          <div style={{padding:6, borderBottom:'1px solid #eee', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
            <div style={{display:'flex', gap:12, alignItems:'center'}}>
              <div style={{fontSize:13, color:'#444'}}>Game data loaded</div>
                <div style={{fontSize:12, color:'#444'}}>Pending syncs: {queueLen}</div>
            </div>
            <div>
              <button className="button" onClick={() => { state.refresh && state.refresh() }}>Refresh</button>
            </div>
          </div>
        )}
        {pendingActions && pendingActions.length > 0 ? (
          <div style={{padding:8, borderTop:'1px solid #eee', background:'#f7f7f7'}}>
            <div style={{fontSize:12, color:'#333'}}><strong>Pending actions</strong></div>
            <div style={{display:'flex', gap:8, marginTop:6}}>
              {pendingActions.map(a => (
                <div key={a.actionId} style={{padding:6, border:'1px solid #ddd', borderRadius:6, background:'#fff'}}>
                  <div style={{fontSize:12}}>{a.type}</div>
                  <div style={{fontSize:11, color:'#666'}}>{a.actionId}</div>
                  <div style={{marginTop:6}}>
                    <button className="button" onClick={() => undoAction(a.actionId)} style={{fontSize:12}}>Undo</button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ) : null}
        {children ?? null}
      </div>
    </GameDataContext.Provider>
  )
};

export const useGameData = () => useContext(GameDataContext);

export default GameDataContext;
