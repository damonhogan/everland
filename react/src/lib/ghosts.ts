export type Ghost = { id: string; author: string; data: any; timestamp: number }
const KEY = 'everland_ghosts'

export function loadGhosts(): Ghost[] { try { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : [] } catch(e){return []} }
export function saveGhosts(g: Ghost[]) { try { localStorage.setItem(KEY, JSON.stringify(g)) } catch(e){} }
export function addGhost(author: string, data: any) { const g = loadGhosts(); g.unshift({ id: String(Date.now())+'-'+Math.floor(Math.random()*1000), author, data, timestamp: Date.now() }); saveGhosts(g.slice(0,50)) }
export function clearGhosts(){ saveGhosts([]) }
