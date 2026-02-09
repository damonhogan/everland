import React, { useEffect, useState } from 'react'

export default function LorePanel() {
  const [text, setText] = useState<string | null>(null)
  useEffect(() => {
    fetch('/bbs/everland_lore.txt').then(r => {
      if (!r.ok) throw new Error('not found')
      return r.text()
    }).then(t => setText(t)).catch(() => setText(null))
  }, [])

  if (text === null) return (
    <div className="lore-panel">
      <h3>Lore</h3>
      <div style={{fontStyle:'italic', color:'#666'}}>No lore file found. Place everland_lore.txt into the react/ folder and run `npm run generate:assets`.</div>
    </div>
  )

  return (
    <div className="lore-panel">
      <h3>Lore</h3>
      <div style={{whiteSpace:'pre-wrap', maxHeight:240, overflow:'auto', padding:8, background:'#fff'}}>{text}</div>
    </div>
  )
}
