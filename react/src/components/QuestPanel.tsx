import React from 'react'
import type { Quest } from '../lib/quests'
import { canCompleteQuest, consumeRequirements } from '../lib/quests'
import type { InventoryItem } from '../lib/crafting'
import { useGameData } from '../context/GameDataContext'

export default function QuestPanel({ quests, setQuests, inventory, setInventory, addToast }: { quests?: Quest[]; setQuests?: (q: Quest[]) => void; inventory: InventoryItem[]; setInventory: (i: InventoryItem[]) => void; addToast?: (m:string)=>void }) {
  const gd = useGameData()
  const names = gd.data?.items || {}
  const usedQuests = quests ?? (gd.data?.quests ?? [])
  const usedSetQuests = setQuests ?? gd.setQuests
  const usedDispatch = (gd as any).questsDispatch as ((a:{type:string,payload?:any})=>void) | undefined
  const [pendingIds, setPendingIds] = React.useState<number[]>([])

  function markPending(id: number) {
    setPendingIds(p => Array.from(new Set([...p, id])))
    setTimeout(() => setPendingIds(p => p.filter(x => x !== id)), 700)
  }

  const accept = (id: number) => {
    if (usedDispatch) {
      usedDispatch({ type: 'accept', payload: { id } })
    } else {
      const next = usedQuests.map((q: Quest) => q.id === id ? { ...q, state: 'accepted' } : q)
      if (usedSetQuests) usedSetQuests(next)
    }
    markPending(id)
    const q = usedQuests.find((x: Quest) => x.id === id)
    if (q && addToast) addToast(`Accepted quest: ${q.title} (optimistic)`)
  }

  const complete = (id: number) => {
    const q = usedQuests.find((x: Quest) => x.id === id)
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
    if (usedDispatch) {
      usedDispatch({ type: 'complete', payload: { id } })
    } else {
      const next = usedQuests.map((x: Quest) => x.id === id ? { ...x, completed: true, state: 'completed' } : x)
      if (usedSetQuests) usedSetQuests(next)
    }
    markPending(id)
    if (addToast) addToast(`Quest complete: ${q.title} (optimistic)`)
  }

  return (
    <div style={{marginTop:12}}>
      <h3 style={{display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <span>Quest Board</span>
        <span>
          <button className="button" onClick={() => {
            const toSave = usedQuests
            try {
              const blob = new Blob([JSON.stringify(toSave, null, 2)], { type: 'application/json' })
              const url = URL.createObjectURL(blob)
              const a = document.createElement('a')
              a.href = url
              a.download = `quests-${Date.now()}.json`
              a.click()
              URL.revokeObjectURL(url)
              if (addToast) addToast('Exported quests')
            } catch (e) { if (addToast) addToast('Export failed') }
          }}>Save quests</button>
        </span>
      </h3>
      {usedQuests.map(q => (
        <div key={q.id} className="recipe">
          <div><strong>{q.title}</strong> {q.state === 'completed' ? '(Completed)' : q.state === 'accepted' ? '(Accepted)' : q.state === 'in_progress' ? '(In Progress)' : ''} {pendingIds.includes(q.id) ? <small style={{marginLeft:8, color:'#666'}}>Updating…</small> : null}</div>
          <div>{q.description}</div>
          <div><strong>Requires:</strong> {q.requirements.map(r => `${(names as any)[String(r.itemId)] ?? '#'+r.itemId} x${r.qty}`).join(', ')}</div>
          <div><strong>Rewards:</strong> {q.reward.map(r => `${(names as any)[String(r.itemId)] ?? '#'+r.itemId} x${r.qty}`).join(', ')}</div>
          <div style={{marginTop:6}}>
            <details>
              <summary>Triggers / Prerequisites</summary>
              <div style={{marginTop:6}}>
                <div>Triggers: {q.triggers ? JSON.stringify(q.triggers) : '[]'}</div>
                <div style={{marginTop:6}}>
                  <label style={{display:'block', marginBottom:6}}>Add Trigger</label>
                  <div style={{display:'flex', gap:8, alignItems:'center'}}>
                    <input placeholder="type (eg. crime)" defaultValue="crime" id={`tr-type-${q.id}`} style={{width:140}} />
                    <select id={`tr-op-${q.id}`} defaultValue="==">
                      <option value="==">==</option>
                      <option value=">=">&gt;=</option>
                      <option value="<=">&lt;=</option>
                      <option value=">">&gt;</option>
                      <option value="<">&lt;</option>
                      <option value="contains">contains</option>
                    </select>
                    <input placeholder="key (optional)" id={`tr-key-${q.id}`} style={{width:120}} />
                    <input placeholder="value (optional)" id={`tr-val-${q.id}`} style={{width:120}} />
                    <select id={`tr-action-${q.id}`} defaultValue="accept">
                      <option value="accept">accept</option>
                      <option value="increment">increment</option>
                      <option value="complete">complete</option>
                    </select>
                    <input placeholder="incr (opt)" id={`tr-incr-${q.id}`} style={{width:80}} />
                    <button className="button" onClick={() => {
                      const t = (document.getElementById(`tr-type-${q.id}`) as HTMLInputElement).value || 'crime'
                      const op = (document.getElementById(`tr-op-${q.id}`) as HTMLSelectElement).value
                      const k = (document.getElementById(`tr-key-${q.id}`) as HTMLInputElement).value
                      const v = (document.getElementById(`tr-val-${q.id}`) as HTMLInputElement).value
                      const action = (document.getElementById(`tr-action-${q.id}`) as HTMLSelectElement).value as any
                      const incrRaw = (document.getElementById(`tr-incr-${q.id}`) as HTMLInputElement).value
                      const trig: any = { type: t, op, action }
                      if (k) trig.key = k
                      if (v) trig.value = isNaN(Number(v)) ? v : Number(v)
                      if (incrRaw) trig.incr = Number(incrRaw)
                      if (usedDispatch) usedDispatch({ type: 'add_trigger', payload: { id: q.id, trigger: trig } })
                      else {
                        const next = usedQuests.map((x: Quest) => x.id === q.id ? { ...x, triggers: [ ...(x.triggers||[]), trig ] } : x)
                        if (usedSetQuests) usedSetQuests(next)
                      }
                      markPending(q.id)
                      if (addToast) addToast('Added trigger (optimistic)')
                    }}>Add</button>
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      if (usedDispatch) usedDispatch({ type: 'clear_triggers', payload: { id: q.id } })
                      else {
                        const next = usedQuests.map((x: Quest) => x.id === q.id ? { ...x, triggers: [] } : x)
                        if (usedSetQuests) usedSetQuests(next)
                      }
                      markPending(q.id)
                      if (addToast) addToast('Cleared triggers (optimistic)')
                    }}>Clear</button>
                  </div>

                  <div style={{marginTop:8}}>
                    <label>Prerequisites (comma-separated quest ids)</label>
                    <input placeholder="e.g. 1,2" defaultValue={q.prerequisites ? q.prerequisites.join(',') : ''} id={`pr-${q.id}`} style={{width:220, marginLeft:8}} />
                      <button className="button" style={{marginLeft:8}} onClick={() => {
                      const v = (document.getElementById(`pr-${q.id}`) as HTMLInputElement).value
                      const arr = v.split(',').map(s => Number(s.trim())).filter(n => !Number.isNaN(n))
                      if (usedDispatch) usedDispatch({ type: 'update_prereqs', payload: { id: q.id, prerequisites: arr } })
                      else {
                        const next = usedQuests.map((x: Quest) => x.id === q.id ? { ...x, prerequisites: arr } : x)
                        if (usedSetQuests) usedSetQuests(next)
                      }
                      markPending(q.id)
                      if (addToast) addToast('Updated prerequisites (optimistic)')
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
      <div style={{marginTop:12}}>
        <label>Import quests JSON: </label>
        <select id="quests-import-strat" defaultValue="replace" style={{marginLeft:8}}>
          <option value="replace">Replace all</option>
          <option value="merge-overwrite">Merge (overwrite by id)</option>
          <option value="merge-add-only">Merge (add only)</option>
        </select>
        <input type="file" accept="application/json" id="quests-import" style={{marginLeft:8}} onChange={async (e) => {
          const f = e.currentTarget.files && e.currentTarget.files[0]
          if (!f) return
          try {
            const txt = await f.text()
            const parsed = JSON.parse(txt)
            if (!Array.isArray(parsed)) throw new Error('Not an array')

            // simple validation
            const validateQuest = (q: any) => {
              if (!q) return false
              if (q.id === undefined) return false
              if (typeof q.title === 'undefined') return false
              return true
            }
            for (const p of parsed) if (!validateQuest(p)) throw new Error('Invalid quest shape')

            const strat = (document.getElementById('quests-import-strat') as HTMLSelectElement).value
            let result: any[] = []
            if (strat === 'replace') {
              result = parsed
            } else if (strat === 'merge-overwrite') {
              const byId: Record<string, any> = {}
              for (const q of usedQuests) byId[String(q.id)] = q
              for (const q of parsed) byId[String(q.id)] = q
              result = Object.values(byId)
            } else if (strat === 'merge-add-only') {
              const ids = new Set((usedQuests || []).map((x:any) => String(x.id)))
              result = [...(usedQuests || [])]
              for (const q of parsed) if (!ids.has(String(q.id))) result.push(q)
            }

            if (usedDispatch) usedDispatch({ type: 'replace', payload: result })
            else if (usedSetQuests) usedSetQuests(result)
            if (addToast) addToast('Imported quests (optimistic)')
          } catch (err) {
            if (addToast) addToast('Import failed: ' + String(err))
          }
        }} />

        <button className="button" style={{marginLeft:12}} onClick={async () => {
          if (!usedQuests) return
          const syncFn = (gd as any).syncToServer as ((q:any[])=>Promise<void>) | undefined
          if (syncFn) {
            try {
              await syncFn(usedQuests)
              if (addToast) addToast('Sync sent')
            } catch (e) {
              if (addToast) addToast('Sync queued for retry')
            }
            return
          }

          // fallback: immediate retries
          const postWithRetry = async (url: string, body: any, attempts = 3) => {
            let lastErr: any = null
            for (let i = 0; i < attempts; i++) {
              try {
                const res = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
                if (!res.ok) throw new Error('Status ' + res.status)
                return res
              } catch (err) {
                lastErr = err
                const delay = 300 * Math.pow(2, i)
                await new Promise(r => setTimeout(r, delay))
              }
            }
            throw lastErr
          }

          try {
            await postWithRetry('/api/quests', usedQuests, 3)
            if (addToast) addToast('Synced quests to server')
          } catch (e) {
            if (addToast) addToast('Sync failed after retries')
          }
        }}>Sync to server</button>
      </div>
    </div>
  )
}
