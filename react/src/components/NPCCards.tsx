import React, { useEffect, useState } from 'react'

type NPC = {
  id: string
  name: string
  role: string
  short_blurb: string
  goals?: string[]
  secrets?: string[]
  voice_lines?: string[]
  costume?: string
  props?: string[]
  friendly?: boolean
}

export default function NPCCards() {
  const [npcs, setNpcs] = useState<NPC[] | null>(null)
  useEffect(() => {
    fetch('/bbs/npcs_cards.json').then(r => r.json()).then(j => setNpcs(Array.isArray(j) ? j : null)).catch(() => setNpcs(null))
  }, [])

  if (!npcs) return (
    <div className="npc-cards">
      <h3>NPC Cards</h3>
      <div style={{fontStyle:'italic', color:'#666'}}>No NPC cards found. Place `npcs_cards.json` into `react/public/bbs`.</div>
    </div>
  )

  const printable = () => window.print()

  return (
    <div className="npc-cards">
      <h3>NPC Cards</h3>
      <div style={{marginBottom:8}}>
        <button className="button" onClick={printable}>Print NPC Cards</button>
      </div>
      <div style={{display:'grid', gridTemplateColumns:'repeat(2,1fr)', gap:12}}>
        {npcs.map(n => (
          <div key={n.id} style={{padding:12, border:'1px solid #ccc', borderRadius:6, background:'#fff'}}>
            <div style={{display:'flex', justifyContent:'space-between', alignItems:'baseline'}}>
              <strong>{n.name}</strong>
              <span style={{fontSize:12, color:'#666'}}>{n.role}</span>
            </div>
            <div style={{marginTop:6, fontSize:13}}>{n.short_blurb}</div>
            {n.goals && n.goals.length>0 ? (
              <div style={{marginTop:8}}><strong>Goals:</strong><ul>{n.goals.map(g => <li key={g}>{g}</li>)}</ul></div>
            ) : null}
            {n.voice_lines && n.voice_lines.length>0 ? (
              <div style={{marginTop:6}}><strong>Voice:</strong><div style={{fontSize:12,color:'#333'}}>{n.voice_lines[0]}</div></div>
            ) : null}
            {n.costume ? (<div style={{marginTop:8,fontSize:12,color:'#444'}}><strong>Costume:</strong> {n.costume}</div>) : null}
            {n.props && n.props.length>0 ? (<div style={{marginTop:6,fontSize:12}}><strong>Props:</strong> {n.props.join(', ')}</div>) : null}
            {typeof n.friendly !== 'undefined' ? (<div style={{marginTop:8,fontSize:12,color:n.friendly ? '#0a0' : '#a00'}}><strong>{n.friendly ? 'Ally' : 'Antagonist'}</strong></div>) : null}
          </div>
        ))}
      </div>
    </div>
  )
}
