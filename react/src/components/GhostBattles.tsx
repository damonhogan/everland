import React, { useEffect, useState } from 'react'
import { loadGhosts, addGhost, clearGhosts } from '../lib/ghosts'

export default function GhostBattles({ addToast }: { addToast?: (m:string)=>void }){
  const [ghosts, setGhosts] = useState<any[]>([])
  useEffect(()=> setGhosts(loadGhosts()), [])
  const [author, setAuthor] = useState('Player')
  const [payload, setPayload] = useState('')

  function save() { addGhost(author||'Player', payload || {}); setGhosts(loadGhosts()); if (addToast) addToast('Saved ghost') }
  function clearAll(){ clearGhosts(); setGhosts([]); if (addToast) addToast('Cleared ghosts') }

  return (
    <div style={{marginTop:12}}>
      <h3>Ghost Battles</h3>
      <div>
        <input value={author} onChange={e=>setAuthor(e.target.value)} />
        <button className="button" style={{marginLeft:8}} onClick={clearAll}>Clear</button>
      </div>
      <div style={{marginTop:8}}>
        <textarea rows={3} style={{width:'100%'}} value={payload} onChange={e=>setPayload(e.target.value)} />
        <div style={{marginTop:6}}>
          <button className="button" onClick={save}>Save Ghost</button>
        </div>
      </div>
      <div style={{marginTop:12}}>
        {ghosts.map((g:any) => (<div key={g.id} style={{padding:8, borderBottom:'1px solid #eee'}}><div style={{fontSize:12,color:'#666'}}>{g.author} — {new Date(g.timestamp).toLocaleString()}</div><pre style={{whiteSpace:'pre-wrap'}}>{String(g.data)}</pre></div>))}
      </div>
    </div>
  )
}
