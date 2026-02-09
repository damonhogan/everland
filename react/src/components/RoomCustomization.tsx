import React, { useEffect, useState } from 'react'

const KEY = 'everland_room'

type Room = { title?: string; description?: string; decor?: number; ascii?: string }

function load(): Room { try { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : {} } catch(e){return{}} }
function save(r: Room) { try { localStorage.setItem(KEY, JSON.stringify(r)) } catch(e){} }

export default function RoomCustomization({ addToast }: { addToast?: (m:string)=>void }){
  const [room, setRoom] = useState<Room>({})
  useEffect(()=> setRoom(load()), [])

  function update() { save(room); if (addToast) addToast('Room saved') }

  return (
    <div style={{marginTop:12}}>
      <h3>Room Customization</h3>
      <div style={{marginBottom:8}}>
        <label>Title</label><br/>
        <input value={room.title||''} onChange={e=>setRoom({...room, title:e.target.value})} style={{width:'100%'}} />
      </div>
      <div style={{marginBottom:8}}>
        <label>Description</label><br/>
        <textarea value={room.description||''} onChange={e=>setRoom({...room, description:e.target.value})} rows={3} style={{width:'100%'}} />
      </div>
      <div style={{marginBottom:8}}>
        <label>ASCII Art</label><br/>
        <textarea value={room.ascii||''} onChange={e=>setRoom({...room, ascii:e.target.value})} rows={4} style={{width:'100%'}} />
      </div>
      <div>
        <button className="button" onClick={update}>Save Room</button>
      </div>
    </div>
  )
}
