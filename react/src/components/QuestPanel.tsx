import React from 'react'
import type { Quest } from '../lib/quests'
import { canCompleteQuest, consumeRequirements } from '../lib/quests'
import type { InventoryItem } from '../lib/crafting'

export default function QuestPanel({ quests, setQuests, inventory, setInventory, names, addToast }: { quests: Quest[]; setQuests: (q: Quest[]) => void; inventory: InventoryItem[]; setInventory: (i: InventoryItem[]) => void; names: Record<string,string>, addToast?: (m:string)=>void }) {
  const accept = (id: number) => {
    setQuests(quests.map(q => q.id === id ? { ...q, accepted: true } : q))
    const q = quests.find(x => x.id === id)
    if (q && addToast) addToast(`Accepted quest: ${q.title}`)
  }

  const complete = (id: number) => {
    const q = quests.find(x => x.id === id)
    if (!q) return
    if (!canCompleteQuest(q, inventory)) { if (addToast) addToast('You do not meet the requirements'); return }
    const newInv = consumeRequirements(inventory, q)
    if (!newInv) { if (addToast) addToast('Consume failed'); return }
    // apply rewards
    for (const r of q.reward) {
      const ex = newInv.find(e => e.itemId === r.itemId)
      if (ex) ex.qty += r.qty
      else newInv.push({ itemId: r.itemId, qty: r.qty })
    }
    setInventory(newInv)
    setQuests(quests.map(x => x.id === id ? { ...x, completed: true } : x))
    if (addToast) addToast(`Quest complete: ${q.title}`)
  }

  return (
    <div style={{marginTop:12}}>
      <h3>Quest Board</h3>
      {quests.map(q => (
        <div key={q.id} className="recipe">
          <div><strong>{q.title}</strong> {q.completed ? '(Completed)' : q.accepted ? '(Accepted)' : ''}</div>
          <div>{q.description}</div>
          <div><strong>Requires:</strong> {q.requirements.map(r => `${names[String(r.itemId)] ?? '#'+r.itemId} x${r.qty}`).join(', ')}</div>
          <div><strong>Rewards:</strong> {q.reward.map(r => `${names[String(r.itemId)] ?? '#'+r.itemId} x${r.qty}`).join(', ')}</div>
          <div style={{marginTop:6}}>
            <details>
              <summary>Triggers / Prerequisites</summary>
              <div style={{marginTop:6}}>
                <div>Triggers: {q.triggers ? JSON.stringify(q.triggers) : '[]'}</div>
                <div style={{marginTop:6}}>
                  <label style={{display:'block', marginBottom:6}}>Add Trigger</label>
                  <div style={{display:'flex', gap:8, alignItems:'center'}}>
                    <input placeholder="type (eg. crime)" defaultValue="crime" id={`tr-type-${q.id}`} style={{width:140}} />
                    <input placeholder="key (optional)" id={`tr-key-${q.id}`} style={{width:120}} />
                    <input placeholder="value (optional)" id={`tr-val-${q.id}`} style={{width:120}} />
                    <button className="button" onClick={() => {
                      const t = (document.getElementById(`tr-type-${q.id}`) as HTMLInputElement).value || 'crime'
                      const k = (document.getElementById(`tr-key-${q.id}`) as HTMLInputElement).value
                      const v = (document.getElementById(`tr-val-${q.id}`) as HTMLInputElement).value
                      const trig: any = { type: t }
                      if (k) trig.key = k
                      if (v) trig.value = isNaN(Number(v)) ? v : Number(v)
                      const next = quests.map(x => x.id === q.id ? { ...x, triggers: [ ...(x.triggers||[]), trig ] } : x)
                      setQuests(next)
                      if (addToast) addToast('Added trigger')
                    }}>Add</button>
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      const next = quests.map(x => x.id === q.id ? { ...x, triggers: [] } : x)
                      setQuests(next)
                      if (addToast) addToast('Cleared triggers')
                    }}>Clear</button>
                  </div>

                  <div style={{marginTop:8}}>
                    <label>Prerequisites (comma-separated quest ids)</label>
                    <input placeholder="e.g. 1,2" defaultValue={q.prerequisites ? q.prerequisites.join(',') : ''} id={`pr-${q.id}`} style={{width:220, marginLeft:8}} />
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      const v = (document.getElementById(`pr-${q.id}`) as HTMLInputElement).value
                      const arr = v.split(',').map(s => Number(s.trim())).filter(n => !Number.isNaN(n))
                      const next = quests.map(x => x.id === q.id ? { ...x, prerequisites: arr } : x)
                      setQuests(next)
                      if (addToast) addToast('Updated prerequisites')
                    }}>Save</button>
                  </div>
                </div>
              </div>
            </details>
          </div>
          <div style={{marginTop:6}}>
            {!q.accepted && !q.completed && <button className="button" onClick={() => accept(q.id)}>Accept</button>}
            {q.accepted && !q.completed && <button className="button" onClick={() => complete(q.id)}>Complete</button>}
          </div>
        </div>
      ))}
    </div>
  )
}
