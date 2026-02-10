import React, { useEffect, useState } from 'react'
import AudioManager from '../lib/AudioManager'

export default function GMDashboard() {
  const [tracks, setTracks] = useState<Array<any>>([])
  const [selected, setSelected] = useState<string | null>(null)
  const [volume, setVolume] = useState<number>(0.6)
  const [rumor, setRumor] = useState('')
  const [token, setToken] = useState<string>(localStorage.getItem('gm_token') || '')

  useEffect(() => {
    fetch('/bbs/audio_assets.json').then(r => r.json()).then(j => setTracks(j.tracks || [])).catch(() => setTracks([]))
  }, [])

  useEffect(() => {
    AudioManager.setVolume(volume)
  }, [volume])

  function play() {
    if (!selected) return
    AudioManager.play(selected)
  }

  function stop() { AudioManager.stop() }

  function broadcastRumor() {
    if (!rumor) return
    // POST to server so other clients / server-side logs can observe
    try {
      const headers: any = { 'content-type': 'application/json' }
      if (token) headers['x-gm-token'] = token
      fetch('/api/gm/rumor', { method: 'POST', headers, body: JSON.stringify({ text: rumor }) }).catch(() => {})
    } catch (e) {}
    // also dispatch local event for in-page subscribers
    try { window.dispatchEvent(new CustomEvent('gm:rumor', { detail: { text: rumor, time: Date.now() } })) } catch (e) {}
    setRumor('')
    console.info('GM broadcast rumor:', rumor)
  }

  function saveToken() {
    try { localStorage.setItem('gm_token', token) } catch (e) {}
  }

  return (
    <div style={{border:'1px solid #ddd', padding:8, borderRadius:6, marginTop:8}}>
      <h3>GM Dashboard</h3>
      <div style={{display:'flex', gap:8, alignItems:'center'}}>
        <select value={selected || ''} onChange={(e) => setSelected(e.target.value)}>
          <option value="">(select ambience)</option>
          {tracks.map(t => <option key={t.id} value={t.id}>{t.title}</option>)}
        </select>
        <button className="button" onClick={play}>Play</button>
        <button className="button" onClick={stop}>Stop</button>
        <label style={{marginLeft:8}}>Volume
          <input type="range" min={0} max={1} step={0.01} value={String(volume)} onChange={(e) => setVolume(Number(e.target.value))} />
        </label>
      </div>

      <div style={{marginTop:8}}>
        <label style={{fontSize:12, color:'#666'}}>GM Token (optional)</label>
        <div style={{display:'flex', gap:8, marginTop:6}}>
          <input style={{flex:1}} value={token} onChange={(e) => setToken(e.target.value)} placeholder="paste GM token here" />
          <button className="button" onClick={saveToken}>Save</button>
        </div>
      </div>

      <div style={{marginTop:12}}>
        <label>Broadcast Rumor to players (fires `gm:rumor` event)</label>
        <div style={{display:'flex', gap:8, marginTop:6}}>
          <input style={{flex:1}} value={rumor} onChange={(e) => setRumor(e.target.value)} placeholder="Whisper something ominous..." />
          <button className="button" onClick={broadcastRumor}>Broadcast</button>
        </div>
      </div>
    </div>
  )
}
