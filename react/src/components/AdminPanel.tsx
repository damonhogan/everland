import React, { useEffect, useState } from 'react'

export default function AdminPanel() {
  const [adminSecret, setAdminSecret] = useState(localStorage.getItem('admin_secret') || '')
  const [tokens, setTokens] = useState<any[]>([])
  const [label, setLabel] = useState('')
  const [rumors, setRumors] = useState<any[]>([])
  const [pending, setPending] = useState<any>({ items: [] })
  const [publishChoice, setPublishChoice] = useState<Record<string,string>>({})

  function saveSecret() { try { localStorage.setItem('admin_secret', adminSecret) } catch (e) {} }

  async function loadTokens() {
    try {
      const h: any = {}
      if (adminSecret) h['x-admin-secret'] = adminSecret
      const r = await fetch('/api/gm/tokens', { headers: h })
      if (!r.ok) return
      const j = await r.json()
      setTokens(j || [])
    } catch (e) {}
  }

  async function createToken() {
    try {
      const h: any = { 'content-type': 'application/json' }
      if (adminSecret) h['x-admin-secret'] = adminSecret
      const r = await fetch('/api/gm/tokens', { method: 'POST', headers: h, body: JSON.stringify({ label }) })
      if (!r.ok) { loadTokens(); return }
      const j = await r.json()
      setTokens(t => [j, ...t])
      setLabel('')
    } catch (e) {}
  }

  async function revoke(id: string) {
    try {
      const h: any = {}
      if (adminSecret) h['x-admin-secret'] = adminSecret
      await fetch('/api/gm/tokens/' + id, { method: 'DELETE', headers: h })
      loadTokens()
    } catch (e) {}
  }

  useEffect(() => { loadTokens(); fetchRumors() }, [])

  async function loadPending() {
    try {
      const h: any = {}
      if (adminSecret) h['x-admin-secret'] = adminSecret
      const r = await fetch('/api/admin/pending', { headers: h })
      if (!r.ok) return
      const j = await r.json()
      setPending(j || { items: [] })
    } catch (e) {}
  }

  async function approveCandidate(videoId: string, candidateId: string, publishTo: string) {
    try {
      const h: any = { 'content-type': 'application/json' }
      if (adminSecret) h['x-admin-secret'] = adminSecret
      const r = await fetch('/api/admin/approve', { method: 'POST', headers: h, body: JSON.stringify({ videoId, candidateId, publishTo }) })
      if (!r.ok) { await loadPending(); return }
      await loadPending();
    } catch (e) {}
  }

  async function fetchRumors() {
    try { const r = await fetch('/api/gm/rumors'); if (!r.ok) return; const j = await r.json(); setRumors(j || []) } catch (e) {}
  }

  return (
    <div style={{border:'1px solid #ccc', padding:8, borderRadius:6, marginTop:8}}>
      <h3>Admin Panel</h3>
      <div style={{marginBottom:8}}>
        <label style={{fontSize:12}}>Admin secret</label>
        <div style={{display:'flex', gap:8, marginTop:6}}>
          <input value={adminSecret} onChange={e=>setAdminSecret(e.target.value)} placeholder="admin secret" />
          <button className="button" onClick={saveSecret}>Save</button>
          <button className="button" onClick={loadTokens}>Refresh</button>
        </div>
      </div>

      <div style={{marginTop:8}}>
        <h4>GM Tokens</h4>
        <div style={{display:'flex', gap:8}}>
          <input value={label} onChange={e=>setLabel(e.target.value)} placeholder="label (eg. 'Main GM')" />
          <button className="button" onClick={createToken}>Create</button>
        </div>
        <div style={{marginTop:8}}>
          {tokens.map(t => (
            <div key={t.id} style={{padding:6, borderBottom:'1px solid #eee'}}>
              <div><strong>{t.label}</strong> <span style={{color:'#666'}}>({t.id})</span></div>
              <div style={{fontFamily:'monospace'}}>{t.token}</div>
              <div><button className="button" onClick={()=>revoke(t.id)}>Revoke</button></div>
            </div>
          ))}
        </div>
      </div>

      <div style={{marginTop:12}}>
        <h4>Recent Rumors</h4>
        <div style={{maxHeight:160, overflow:'auto'}}>
          {rumors.map(r => <div key={r.id} style={{padding:6, borderBottom:'1px solid #eee'}}>{new Date(r.time).toLocaleString()} — {r.text}</div>)}
        </div>
        <div style={{marginTop:8}}><button className="button" onClick={fetchRumors}>Refresh</button></div>
      </div>
      <div style={{marginTop:12}}>
        <h4>Pending Assets</h4>
        <div style={{maxHeight:220, overflow:'auto'}}>
          {(pending.items||[]).map((it:any) => (
            <div key={it.videoId} style={{padding:8, borderBottom:'1px solid #eee'}}>
              <div style={{fontWeight:600}}>{it.title} <span style={{color:'#666'}}>{it.videoId}</span></div>
              <div style={{display:'flex', gap:12, marginTop:6}}>
                {(it.candidates||[]).map((c:any) => {
                  const defaultChoice = c.type === 'audio' ? 'audio' : c.type === 'npc_lines' ? 'npc_lines' : c.type === 'image' ? 'image' : 'npc_lines'
                  const sel = publishChoice[c.id] || defaultChoice
                  return (
                  <div key={c.id} style={{border:'1px solid #ddd', padding:6, borderRadius:6, width:220}}>
                    <div style={{fontSize:13, fontWeight:600}}>{c.title}</div>
                    <div style={{fontSize:12, color:'#444'}}>{c.type}</div>
                    {c.type === 'audio' && c.src ? <div style={{marginTop:6}}><audio controls src={c.src} style={{width:'100%'}} /></div> : null}
                    {c.type === 'image' && c.src ? <div style={{marginTop:6}}><img src={c.src} alt={c.title} style={{maxWidth:200, maxHeight:120}}/></div> : null}
                    {c.src && c.type !== 'audio' && c.type !== 'image' ? <div style={{marginTop:6}}><a href={c.src} target="_blank" rel="noreferrer">open</a></div> : null}
                    {c.suggestedLines ? <div style={{marginTop:6, fontSize:12}}>{(c.suggestedLines||[]).slice(0,3).map((l:any,i:number)=>(<div key={i}>- {l}</div>))}</div> : null}
                    <div style={{marginTop:8, display:'flex', gap:6, alignItems:'center'}}>
                      <select value={sel} onChange={e=>setPublishChoice(p=>({ ...p, [c.id]: e.target.value }))}>
                        <option value="audio">Publish as audio</option>
                        <option value="npc_lines">Publish as NPC lines</option>
                        <option value="scene">Publish as Scene</option>
                        <option value="image">Publish as Image</option>
                      </select>
                      <button className="button" onClick={()=>approveCandidate(it.videoId, c.id, publishChoice[c.id] || defaultChoice)}>Approve</button>
                    </div>
                  </div>
                )})}
              </div>
            </div>
          ))}
        </div>
        <div style={{marginTop:8}}><button className="button" onClick={loadPending}>Refresh</button></div>
      </div>
    </div>
  )
}
