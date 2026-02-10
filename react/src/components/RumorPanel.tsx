import React, { useEffect, useState } from 'react'

export default function RumorPanel() {
  const [rumors, setRumors] = useState<Array<any>>([])

  async function fetchRumors() {
    try {
      const r = await fetch('/api/gm/rumors')
      if (!r.ok) return
      const j = await r.json()
      setRumors(j || [])
    } catch (e) {}
  }

  useEffect(() => {
    fetchRumors()
    // try to open websocket for live updates
    let ws: WebSocket | null = null
    try {
      ws = new WebSocket((location.protocol === 'https:' ? 'wss://' : 'ws://') + location.host)
      ws.addEventListener('message', (m) => {
        try {
          const d = JSON.parse(m.data)
          if (d && d.type === 'rumor' && d.rumor) {
            setRumors(prev => [d.rumor, ...prev].slice(0,50))
          }
        } catch (e) {}
      })
    } catch (e) {}

    const onRumor = (ev: any) => {
      try {
        const d = ev.detail || { text: String(ev) }
        setRumors(prev => [{ id: 'local-'+Date.now(), text: d.text, time: d.time || Date.now(), source: 'gm-local' }, ...prev].slice(0,50))
      } catch (e) {}
    }
    window.addEventListener('gm:rumor', onRumor as EventListener)
    const id = setInterval(fetchRumors, 15000)
    return () => { window.removeEventListener('gm:rumor', onRumor as EventListener); clearInterval(id); if (ws) try { ws.close() } catch (e) {} }
  }, [])

  return (
    <div style={{border:'1px dashed #ccc', padding:8, marginTop:8, borderRadius:6}}>
      <h4>Rumors</h4>
      <div style={{maxHeight:160, overflow:'auto'}}>
        {rumors.length === 0 ? <div style={{color:'#666'}}>No rumors</div> : rumors.map(r => (
          <div key={r.id || r.time} style={{borderBottom:'1px solid #eee', padding:'6px 0'}}>
            <div style={{fontSize:12, color:'#333'}}>{r.text}</div>
            <div style={{fontSize:11, color:'#999'}}>{new Date(r.time||0).toLocaleString()} — {r.source||'gm'}</div>
          </div>
        ))}
      </div>
    </div>
  )
}
