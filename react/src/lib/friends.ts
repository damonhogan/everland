export type Friend = { name: string }
const KEY = 'everland_friends'

export function loadFriends(): Friend[] { try { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : [] } catch(e){return []} }
export function saveFriends(f: Friend[]) { try { localStorage.setItem(KEY, JSON.stringify(f)) } catch(e){} }
export function addFriend(name: string){ const f = loadFriends(); f.push({name}); saveFriends(f) }
export function removeFriend(name:string){ const f = loadFriends().filter(x=>x.name!==name); saveFriends(f) }
export function clearFriends(){ saveFriends([]) }
