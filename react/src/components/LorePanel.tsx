import React, { useEffect, useState } from 'react'

type LoreJson = {
  canonical_summary?: string
  player_summary?: string
  gm_notes?: any
}

export default function LorePanel() {
  const [json, setJson] = useState<LoreJson | null>(null)
  const [raw, setRaw] = useState<string | null>(null)
  const [showGM, setShowGM] = useState(false)

  useEffect(() => {
    // prefer structured lore JSON
    fetch('/bbs/lore.json').then(r => {
      if (!r.ok) throw new Error('no json')
      return r.json()
    }).then(j => setJson(j)).catch(() => {
      // fallback to old text file
      fetch('/bbs/everland_lore.txt').then(r => { if (!r.ok) throw new Error('not found'); return r.text() }).then(t => setRaw(t)).catch(() => setRaw(null))
    })
  }, [])

  if (json === null && raw === null) return (
    <div className="lore-panel">
      <h3>Lore</h3>
      <div style={{fontStyle:'italic', color:'#666'}}>No lore found. Place `lore.json` or `everland_lore.txt` into `react/public/bbs`.</div>
    </div>
  )

  return (
    <div className="lore-panel">
      <h3>Lore</h3>
      {json ? (
        <div>
          <div style={{whiteSpace:'pre-wrap', maxHeight:160, overflow:'auto', padding:8, background:'#fff'}}>{json.player_summary || json.canonical_summary}</div>
          <div style={{marginTop:8}}>
            <button className="button" onClick={() => setShowGM(s => !s)}>{showGM ? 'Hide GM Notes' : 'Show GM Notes'}</button>
          </div>
          {showGM && json.gm_notes ? (
            <div style={{marginTop:8, whiteSpace:'pre-wrap', maxHeight:300, overflow:'auto', padding:8, background:'#fffbe6', border:'1px solid #f0e68c'}}>
              <strong>GM Notes:</strong>
              <div style={{marginTop:6}}>{typeof json.gm_notes === 'string' ? json.gm_notes : JSON.stringify(json.gm_notes, null, 2)}</div>
            </div>
          ) : null}
        </div>
      ) : (
        <div style={{whiteSpace:'pre-wrap', maxHeight:240, overflow:'auto', padding:8, background:'#fff'}}>{raw}</div>
      )}
    </div>
  )
}
