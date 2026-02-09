export type SaveState = {
  version: number
  timestamp: number
  inventory?: any[]
  quests?: any[]
  guardReports?: any[]
  gold?: number
  npcState?: Record<string, any>
}

const KEY = 'everland_save'
const BACKUP_PREFIX = 'everland_save_backup_'
export const CURRENT_VERSION = 2

export function loadLocal(): SaveState | null {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return null
    return JSON.parse(raw) as SaveState
  } catch (e) { return null }
}

export function getLocalRaw(): string | null {
  return localStorage.getItem(KEY)
}

export function saveLocal(state: Omit<SaveState,'version'|'timestamp'>) {
  const wrapped: SaveState = { version: CURRENT_VERSION, timestamp: Date.now(), ...state }
  try { localStorage.setItem(KEY, JSON.stringify(wrapped)) } catch (e) {}
  return wrapped
}

export function backupCurrent(): string | null {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return null
    const k = BACKUP_PREFIX + Date.now()
    localStorage.setItem(k, raw)
    return k
  } catch (e) { return null }
}

export function listBackups(): string[] {
  try {
    const keys: string[] = []
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i)
      if (k && k.startsWith(BACKUP_PREFIX)) keys.push(k)
    }
    // sort by newest first
    keys.sort((a, b) => Number(b.slice(BACKUP_PREFIX.length)) - Number(a.slice(BACKUP_PREFIX.length)))
    return keys
  } catch (e) { return [] }
}

export function restoreBackup(key: string): boolean {
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return false
    // backup current before restoring
    const b = backupCurrent()
    localStorage.setItem(KEY, raw)
    // return true; callers may want the backup key that was created
    ;(restoreBackup as any).lastBackupCreated = b || null
    return true
  } catch (e) { return false }
}

export function restoreBackupWithUndo(key: string): { success: boolean; backupKey?: string | null } {
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return { success: false }
    const b = backupCurrent()
    localStorage.setItem(KEY, raw)
    return { success: true, backupKey: b || null }
  } catch (e) { return { success: false } }
}

export function importSave(parsed: any): { success: boolean; message: string; backupKey?: string } {
  try {
    if (!parsed || typeof parsed !== 'object') return { success: false, message: 'Invalid save file' }
    // always backup current before applying
    const b = backupCurrent()
    const wrapped: SaveState = { version: parsed.version || 1, timestamp: parsed.timestamp || Date.now(), inventory: parsed.inventory || [], quests: parsed.quests || [], guardReports: parsed.guardReports || [], gold: parsed.gold || 0, npcState: parsed.npcState || {} }
    localStorage.setItem(KEY, JSON.stringify(wrapped))
    const note = b ? `Imported (backup: ${b})` : 'Imported'
    return { success: true, message: note, backupKey: b || undefined }
  } catch (e) { return { success: false, message: 'Import failed' } }
}

export function clearLocal() { try { localStorage.removeItem(KEY) } catch (e) {} }
