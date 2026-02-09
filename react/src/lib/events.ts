export type GameEvent = { id: string; time: number; type: string; actor?: string; location?: string; description?: string }

const KEY = 'everland_events'

export function loadEvents(): GameEvent[] {
  try { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : [] } catch (e) { return [] }
}

export function saveEvents(ev: GameEvent[]) {
  try { localStorage.setItem(KEY, JSON.stringify(ev)) } catch (e) {}
}

export function pushEvent(type: string, details: Partial<GameEvent>) {
  const ev = loadEvents()
  const entry: GameEvent = { id: String(Date.now()) + '-' + Math.floor(Math.random()*1000), time: Date.now(), type, ...details }
  ev.unshift(entry)
  saveEvents(ev.slice(0, 200))
  return entry
}

export function clearEvents() { saveEvents([]) }
