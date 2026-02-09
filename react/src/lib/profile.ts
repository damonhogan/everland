export type Profile = { name?: string; bio?: string; title?: string; gamesPlayed?: number; gamesWon?: number; achievements?: number }
const KEY = 'everland_profile'

export function loadProfile(): Profile { try { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : {} } catch(e){return {}} }
export function saveProfile(p: Profile) { try { localStorage.setItem(KEY, JSON.stringify(p)) } catch(e){} }
export function incrementPlayed(){ const p = loadProfile(); p.gamesPlayed = (p.gamesPlayed||0)+1; saveProfile(p) }
