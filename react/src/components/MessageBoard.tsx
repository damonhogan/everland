import React, { useEffect, useState } from 'react'
import { loadPosts, addPost, clearPosts, Post } from '../lib/messageBoard'

export default function MessageBoard({ addToast }: { addToast?: (m:string)=>void }) {
  const [posts, setPosts] = useState<Post[]>([])
  const [author, setAuthor] = useState('Anon')
  const [body, setBody] = useState('')

  useEffect(() => setPosts(loadPosts()), [])

  useEffect(() => {
    const onRumor = (ev: any) => {
      try {
        const d = ev.detail || {}
        const text = d.text || (typeof ev === 'string' ? ev : '')
        if (!text) return
        addPost('GM Rumor', text)
        setPosts(loadPosts())
        if (addToast) addToast('New rumor posted to board')
      } catch (e) {}
    }
    window.addEventListener('gm:rumor', onRumor as EventListener)
    return () => window.removeEventListener('gm:rumor', onRumor as EventListener)
  }, [])

  function submit() {
    if (!body.trim()) { if (addToast) addToast('Empty message'); return }
    addPost(author || 'Anon', body)
    setBody('')
    setPosts(loadPosts())
    if (addToast) addToast('Posted')
  }

  function clearAll() { clearPosts(); setPosts([]); if (addToast) addToast('Cleared messages') }

  return (
    <div style={{marginTop:12}}>
      <h3>Message Board</h3>
      <div style={{marginBottom:8}}>
        <input value={author} onChange={e=>setAuthor(e.target.value)} style={{width:140}} />
        <button className="button" style={{marginLeft:8}} onClick={clearAll}>Clear</button>
      </div>
      <div>
        <textarea rows={4} style={{width:'100%'}} value={body} onChange={e=>setBody(e.target.value)} />
        <div style={{marginTop:6}}>
          <button className="button" onClick={submit}>Post</button>
        </div>
      </div>
      <div style={{marginTop:12}}>
        {posts.map(p => (
          <div key={p.id} style={{padding:8, borderBottom:'1px solid #eee'}}>
            <div style={{fontSize:12, color:'#666'}}>{p.author} — {new Date(p.timestamp).toLocaleString()}</div>
            <div style={{marginTop:6}}>{p.body}</div>
          </div>
        ))}
      </div>
    </div>
  )
}
