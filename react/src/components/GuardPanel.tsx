import React, { useState } from 'react'
import { useGameData } from '../context/GameDataContext'
import { processEventTrigger } from '../lib/quests'
import type { GuardReport } from '../lib/guards'
import { reportCrime, sampleWitnesses } from '../lib/guards'

export default function GuardPanel({ reports, setReports }: { reports?: GuardReport[]; setReports?: (r: GuardReport[]) => void }) {
  const gd = useGameData()
  const [internalReports, setInternalReports] = useState<GuardReport[]>(sampleWitnesses())
  const [loc, setLoc] = useState('Town Square')
  const [desc, setDesc] = useState('')

  const useReports = reports ?? internalReports
  const useSetReports = setReports ?? ((r: GuardReport[]) => setInternalReports(r))

  return (
    <div style={{marginTop:12}}>
      <h3>Guard & Witness Log {gd.status ? `(${gd.status})` : ''}</h3>
      <div>
        {useReports.map(r => (
          <div key={r.id} className="recipe">
            <div><strong>{r.location}</strong> — {new Date(r.time).toLocaleString()}</div>
            <div>{r.description}</div>
          </div>
        ))}
      </div>
      <div style={{marginTop:8}}>
        <input value={loc} onChange={e => setLoc(e.target.value)} />
        <input value={desc} onChange={e => setDesc(e.target.value)} style={{marginLeft:8}} />
        <button className="button" style={{marginLeft:8}} onClick={() => {
          const r = reportCrime(loc, desc)
          useSetReports([r, ...useReports])
          setDesc('')
          // trigger quest event for the report and notify accepted quests
          try {
            const quests = (gd.data && Array.isArray(gd.data.quests)) ? (gd.data.quests as any[]) : []
            const res = processEventTrigger({ type: 'crime', location: loc, description: desc }, quests)
            if (res.accepted && res.accepted.length > 0) {
              const names = res.accepted.join(', ')
              if ((window as any).console) console.log('Quests accepted:', names)
              if ((window as any).everlandAddToast) (window as any).everlandAddToast(`Quests accepted: ${names}`)
            }
            // persist updated quests into the global store if available
            const dispatch = (gd as any).questsDispatch as ((a:{type:string,payload?:any})=>void) | undefined
            if (dispatch) dispatch({ type: 'replace', payload: res.quests })
            else if (gd.setQuests) gd.setQuests(res.quests)
          } catch (e) {
            console.warn('Trigger event failed', e)
          }
        }}>Report</button>
        <button className="button" style={{marginLeft:8}} onClick={() => {
          try {
            const quests = (gd.data && Array.isArray(gd.data.quests)) ? (gd.data.quests as any[]) : []
            const res = processEventTrigger({ type: 'crime', location: loc, description: desc }, quests)
            if (res.accepted && res.accepted.length > 0) {
              const names = res.accepted.join(', ')
              if ((window as any).everlandAddToast) (window as any).everlandAddToast(`Quests accepted: ${names}`)
              else alert(`Quests accepted: ${names}`)
            } else {
              if ((window as any).everlandAddToast) (window as any).everlandAddToast('No quests accepted')
            }
            const dispatch = (gd as any).questsDispatch as ((a:{type:string,payload?:any})=>void) | undefined
            if (dispatch) dispatch({ type: 'replace', payload: res.quests })
            else if (gd.setQuests) gd.setQuests(res.quests)
          } catch (e) { console.warn(e); }
        }}>Trigger Event</button>
        <button className="button" style={{marginLeft:8}} onClick={() => { if (gd.refresh) gd.refresh() }}>Refresh Data</button>
      </div>
    </div>
  )
}
