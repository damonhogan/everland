import React, { useEffect, useState } from 'react'
import { loadHighScores, addHighScore, clearHighScores, HighScore } from '../lib/highscores'
import { useGameData } from '../context/GameDataContext'

export default function HighScores({ addToast }: { addToast?: (m:string)=>void }) {
  const gd = useGameData()
  const [list, setList] = useState<HighScore[]>([])
  const [name, setName] = useState('Player')
  const [score, setScore] = useState(0)

  useEffect(() => setList(loadHighScores()), [])

  function submit() {
    const entry = { name: name || 'Player', score: Number(score) || 0, timestamp: Date.now() }
    addHighScore(entry)
    setList(loadHighScores())
    if (addToast) addToast('High score added')
  }

  function clearAll() { clearHighScores(); setList([]); if (addToast) addToast('High scores cleared') }

  return (
    <div style={{marginTop:12}}>
      <h3>High Scores {gd.status ? `(${gd.status})` : ''}</h3>
      <div style={{marginBottom:8}}>
        <input value={name} onChange={e=>setName(e.target.value)} style={{width:140}} />
        <input type="number" value={score} onChange={e=>setScore(Number(e.target.value))} style={{width:100, marginLeft:8}} />
        <button className="button" style={{marginLeft:8}} onClick={submit}>Submit</button>
        <button className="button" style={{marginLeft:8}} onClick={clearAll}>Clear</button>
      </div>
      <ol>
        {list.map((h,i) => <li key={i}>{h.name} — {h.score} <span style={{color:'#666'}}>({new Date(h.timestamp).toLocaleString()})</span></li>)}
      </ol>
    </div>
  )
}
