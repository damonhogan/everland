import React, { useState } from 'react'
import type { GuardReport } from '../lib/guards'
import { reportCrime, sampleWitnesses } from '../lib/guards'

export default function GuardPanel({ reports, setReports }: { reports?: GuardReport[]; setReports?: (r: GuardReport[]) => void }) {
  const [internalReports, setInternalReports] = useState<GuardReport[]>(sampleWitnesses())
  const [loc, setLoc] = useState('Town Square')
  const [desc, setDesc] = useState('')

  const useReports = reports ?? internalReports
  const useSetReports = setReports ?? ((r: GuardReport[]) => setInternalReports(r))

  return (
    <div style={{marginTop:12}}>
      <h3>Guard & Witness Log</h3>
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
        }}>Report</button>
      </div>
    </div>
  )
}
