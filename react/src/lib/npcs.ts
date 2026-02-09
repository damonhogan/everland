export type NPC = {
  label: string
  name: string
  description: string
  texts: string[]
  bytes: Record<string, number[]>
  unnamedBytes: number[][]
  words: Record<string, number[]>
  unnamedWords: number[][]
  comments: string[]
  raw: string
}

export function parseNumToken(tok: string): number {
  if (!tok) return NaN
  const t = tok.replace(/;.*$/, '').trim()
  if (!t) return NaN
  if (/^\$[0-9A-Fa-f]+$/.test(t)) return parseInt(t.slice(1), 16)
  if (/^0x[0-9A-Fa-f]+$/i.test(t)) return parseInt(t, 16)
  if (/^%[01]+$/.test(t)) return parseInt(t.slice(1), 2)
  const n = Number(t)
  return Number.isNaN(n) ? NaN : n
}

export async function loadNpcs(): Promise<NPC[]> {
  try {
    const res = await fetch('/bbs/npcs_full.json')
    if (!res.ok) return []
    const j = await res.json()
    if (!Array.isArray(j)) return []
    return j as NPC[]
  } catch (e) {
    return []
  }
}

export default loadNpcs
