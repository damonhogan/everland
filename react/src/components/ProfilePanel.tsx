import React, { useEffect, useState } from 'react'
import { loadProfile, saveProfile, Profile } from '../lib/profile'

export default function ProfilePanel({ addToast }: { addToast?: (m:string)=>void }){
  const [p, setP] = useState<Profile>({})
  useEffect(()=> setP(loadProfile()), [])
  function save(){ saveProfile(p); if (addToast) addToast('Profile saved') }
  return (
    <div style={{marginTop:12}}>
      <h3>Player Profile</h3>
      <div>
        <label>Name</label><br/>
        <input value={p.name||''} onChange={e=>setP({...p, name: e.target.value})} />
      </div>
      <div>
        <label>Title</label><br/>
        <input value={p.title||''} onChange={e=>setP({...p, title: e.target.value})} />
      </div>
      <div>
        <label>Bio</label><br/>
        <textarea value={p.bio||''} onChange={e=>setP({...p, bio: e.target.value})} rows={3} style={{width:'100%'}} />
      </div>
      <div style={{marginTop:6}}>
        <button className="button" onClick={save}>Save Profile</button>
      </div>
    </div>
  )
}
