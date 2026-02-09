export type HighScore = { name: string; score: number; timestamp: number }
const KEY = 'everland_hiscores'

export function loadHighScores(): HighScore[] {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return []
    return JSON.parse(raw) as HighScore[]
  } catch (e) { return [] }
}

export function saveHighScores(list: HighScore[]) {
  try { localStorage.setItem(KEY, JSON.stringify(list)) } catch (e) {}
}

export function addHighScore(entry: HighScore) {
  const cur = loadHighScores()
  cur.push(entry)
  cur.sort((a,b) => b.score - a.score || a.timestamp - b.timestamp)
  saveHighScores(cur.slice(0, 20))
}

export function clearHighScores() { saveHighScores([]) }
