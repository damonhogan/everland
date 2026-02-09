import React from 'react'

const SAMPLE = [
  { name: 'Royal Chamber', owner: 'King Arthur', rating: 4 },
  { name: 'Mystic Grove', owner: 'Elara Sage', rating: 5 },
  { name: 'Adventure Den', owner: 'Bold Explorer', rating: 3 },
  { name: 'Peaceful Meadow', owner: 'Tranquil Soul', rating: 5 },
  { name: 'Dark Dungeon', owner: 'Shadow Lord', rating: 2 }
]

export default function SampleRooms({ addToast }: { addToast?: (m:string)=>void }){
  return (
    <div style={{marginTop:12}}>
      <h3>Sample Rooms</h3>
      <ul>
        {SAMPLE.map((s,i)=> <li key={i}><strong>{s.name}</strong> — owner: {s.owner} — rating: {s.rating} <button className="button" style={{marginLeft:8}} onClick={()=> { if (addToast) addToast(`Visiting ${s.name}`) }}>Visit</button></li>)}
      </ul>
    </div>
  )
}
