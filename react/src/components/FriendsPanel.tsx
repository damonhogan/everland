import React, { useEffect, useState } from 'react'
import { loadFriends, addFriend, removeFriend, clearFriends } from '../lib/friends'

export default function FriendsPanel({ addToast }: { addToast?: (m:string)=>void }){
  const [friends, setFriends] = useState<{name:string}[]>([])
  const [name, setName] = useState('')
  useEffect(()=> setFriends(loadFriends()), [])
  function add(){ if (!name.trim()) return; addFriend(name); setFriends(loadFriends()); if (addToast) addToast('Friend added'); setName('') }
  function rem(n:string){ removeFriend(n); setFriends(loadFriends()); if (addToast) addToast('Friend removed') }
  function clearAll(){ clearFriends(); setFriends([]); if (addToast) addToast('Friends cleared') }
  return (
    <div style={{marginTop:12}}>
      <h3>Friends</h3>
      <div>
        <input value={name} onChange={e=>setName(e.target.value)} />
        <button className="button" style={{marginLeft:8}} onClick={add}>Add</button>
        <button className="button" style={{marginLeft:8}} onClick={clearAll}>Clear</button>
      </div>
      <ul>
        {friends.map(f => <li key={f.name}>{f.name} <button className="button" style={{marginLeft:8}} onClick={()=>rem(f.name)}>Remove</button></li>)}
      </ul>
    </div>
  )
}
