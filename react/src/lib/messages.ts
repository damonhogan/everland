export type PrivateMsg = { id: string; from: string; to: string; body: string; timestamp: number }
const KEY = 'everland_private_msgs'

export function loadMessages(): PrivateMsg[] { try { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : [] } catch(e){return []} }
export function saveMessages(m: PrivateMsg[]) { try { localStorage.setItem(KEY, JSON.stringify(m)) } catch(e){} }
export function sendMessage(from:string,to:string,body:string){ const m = loadMessages(); m.unshift({ id: String(Date.now())+'-'+Math.floor(Math.random()*1000), from, to, body, timestamp: Date.now() }); saveMessages(m.slice(0,200)) }
export function clearMessages(){ saveMessages([]) }
