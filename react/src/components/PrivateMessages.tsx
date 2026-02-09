import React, { useEffect, useState } from 'react'
import { loadMessages, sendMessage, clearMessages, PrivateMsg } from '../lib/messages'

export default function PrivateMessages({ localName, addToast }: { localName?: string, addToast?: (m:string)=>void }){
  const [msgs, setMsgs] = useState<PrivateMsg[]>([])
  const [to, setTo] = useState('')
  const [body, setBody] = useState('')
  useEffect(()=> setMsgs(loadMessages()), [])
  function send(){ if (!to.trim() || !body.trim()) { if (addToast) addToast('Empty to/body'); return } sendMessage(localName||'Me', to, body); setMsgs(loadMessages()); setBody(''); if (addToast) addToast('Message sent') }
  function clearAll(){ clearMessages(); setMsgs([]); if (addToast) addToast('Messages cleared') }
  return (
    <div style={{marginTop:12}}>
      <h3>Private Messages</h3>
      <div>
        <input placeholder="To" value={to} onChange={e=>setTo(e.target.value)} />
        <button className="button" style={{marginLeft:8}} onClick={clearAll}>Clear</button>
      </div>
      <div style={{marginTop:8}}>
        <textarea rows={3} style={{width:'100%'}} value={body} onChange={e=>setBody(e.target.value)} />
        <div style={{marginTop:6}}>
          <button className="button" onClick={send}>Send</button>
        </div>
      </div>
      <div style={{marginTop:12}}>
        {msgs.map(m => (<div key={m.id} style={{padding:8, borderBottom:'1px solid #eee'}}><div style={{fontSize:12,color:'#666'}}>From: {m.from} To: {m.to} — {new Date(m.timestamp).toLocaleString()}</div><div style={{marginTop:6}}>{m.body}</div></div>))}
      </div>
    </div>
  )
}
