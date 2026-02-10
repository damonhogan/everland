import React, { useEffect, useState, useRef } from 'react'
import { useGameData } from '../context/GameDataContext'
import { talkToNpc, getPriceForItem, buyItem, sellItem, enqueueDialog, popDialog, ensureRestock, scheduleDialog } from '../lib/npcService'

type Props = {
  npcState: Record<string, any>
  setNpcState: (s: Record<string, any>) => void
  itemNames?: Record<string,string>
  gold?: number
  setGold?: (n: number) => void
  inventory?: { itemId: number, qty: number }[]
  setInventory?: (inv: { itemId: number, qty: number }[]) => void
  addToast?: (m: string) => void
}

export default function NPCPanel({ npcState, setNpcState, itemNames, gold, setGold, inventory, setInventory, addToast }: Props) {
  const gd = useGameData()
  const [npcs, setNpcs] = useState<any[]>([])
  const [selected, setSelected] = useState<string | null>(null)
  const [lastDialog, setLastDialog] = useState<string | null>(null)
  const [editMode, setEditMode] = useState(false)
  const [enqueueText, setEnqueueText] = useState<string>('')
  const [patrolPoint, setPatrolPoint] = useState<string>('')
  const [patrolPoints, setPatrolPoints] = useState<string[]>([])
  const [patrolInterval, setPatrolInterval] = useState<number>(30)
  const [autoExportEnabled, setAutoExportEnabled] = useState<boolean>(false)
  const lastExportRef = useRef<string | null>(null)
  const exportTimerRef = useRef<number | null>(null)
  const [schedDelay, setSchedDelay] = useState<number>(10)
  const [schedText, setSchedText] = useState<string>('')
  const [editName, setEditName] = useState('')
  const [editDesc, setEditDesc] = useState('')
  const [shopPrices, setShopPrices] = useState<Record<string, number>>({})

  useEffect(() => {
    fetch('/bbs/shop.json').then(r => { if (!r.ok) throw new Error('no shop'); return r.json() }).then((sj) => {
      if (Array.isArray(sj)) {
        const map: Record<string, number> = {}
        sj.forEach((it: any) => { if (it && (it.id != null) && (it.price != null)) map[String(it.id)] = Number(it.price) })
        setShopPrices(map)
      }
    }).catch(() => {})
  }, [])

  useEffect(() => {
    if (gd.status === 'ready' && Array.isArray(gd.data?.npcs)) setNpcs(gd.data!.npcs as any[])
  }, [gd.status, gd.data])

  // when selecting an NPC, load any existing patrol points/interval from npcState[selected].edited.patrol
  useEffect(() => {
    if (!selected) return
    const cur = npcState[selected] || {}
    const edited = cur.edited || {}
    const p = edited.patrol || cur.patrol || []
    setPatrolPoints(Array.isArray(p) ? p : [])
    const intervalMs = edited.patrolInterval || cur.patrolInterval || (patrolInterval * 1000)
    setPatrolInterval(Math.round((intervalMs || 30000) / 1000))
  }, [selected, npcState])

  // derive auto-export setting from global npcState entry `_app.autoExport`
  useEffect(() => {
    try {
      const v = (npcState && (npcState._app && npcState._app.autoExport)) ? true : false
      setAutoExportEnabled(Boolean(v))
    } catch (e) {
      // ignore
    }
  }, [npcState])

  // Auto-export edited NPCs when npcState changes (debounced). Downloads `npcs-edited.json` only when enabled.
  useEffect(() => {
    if (!autoExportEnabled) return
    // build edited output same as Export button
    try {
      const out: any[] = []
      for (const lbl of Object.keys(npcState)) {
        const s = npcState[lbl] || {}
        if (s.edited) {
          out.push({ label: lbl, ...s.edited })
        }
      }
      if (out.length === 0) return
      const json = JSON.stringify(out, null, 2)
      if (lastExportRef.current === json) return
      // debounce rapid changes
      if (exportTimerRef.current) window.clearTimeout(exportTimerRef.current)
      exportTimerRef.current = window.setTimeout(() => {
        try {
          const blob = new Blob([json], { type: 'application/json' })
          const url = URL.createObjectURL(blob)
          const a = document.createElement('a')
          a.href = url
          a.download = `npcs-edited.json`
          a.click()
          URL.revokeObjectURL(url)
          lastExportRef.current = json
          if (addToast) addToast('Auto-exported npcs-edited.json')
        } catch (e) {
          console.warn('Auto-export failed', e)
        }
      }, 800)
    } catch (e) {
      // ignore
    }
    return () => { if (exportTimerRef.current) { window.clearTimeout(exportTimerRef.current); exportTimerRef.current = null } }
  }, [npcState, autoExportEnabled])

  function detectShopItems(npc: NPC): number[] {
    const ids: number[] = []
    // look for labelled arrays containing small positive numbers
    for (const k of Object.keys(npc.bytes || {})) {
      const arr = npc.bytes[k]
      if (Array.isArray(arr)) arr.forEach(v => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) })
    }
    // unnamed bytes
    if (Array.isArray(npc.unnamedBytes)) {
      npc.unnamedBytes.forEach(arr => arr.forEach(v => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) }))
    }
    // words as fallback
    for (const k of Object.keys(npc.words || {})) {
      const arr = npc.words[k]
      if (Array.isArray(arr)) arr.forEach(v => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) })
    }
    if (Array.isArray(npc.unnamedWords)) {
      npc.unnamedWords.forEach(arr => arr.forEach(v => { if (typeof v === 'number' && v > 0 && v < 1000) ids.push(v) }))
    }
    // dedupe
    return Array.from(new Set(ids))
  }

  function toggleFlag(label: string, key = 'active') {
    const cur = npcState[label] || {}
    const next = { ...npcState, [label]: { ...cur, [key]: !cur[key] } }
    setNpcState(next)
  }

  return (
    <div className="npc-panel">
      <h3>NPCs</h3>
      <div style={{display:'flex', flexWrap: 'wrap'}}>
        <ul style={{width:220, maxHeight:300, overflow:'auto', marginRight:12}}>
          {npcs.map(n => (
            <li key={n.label} style={{padding:6, borderBottom:'1px solid #ddd', cursor:'pointer'}} onClick={() => setSelected(n.label)}>
              <strong>{n.name || n.label}</strong>
              <div style={{fontSize:12, color:'#666'}}>{n.label}</div>
            </li>
          ))}
        </ul>
        <div style={{flex:1, minWidth:320}}>
          {selected ? (
            (() => {
              const npc = npcs.find(x => x.label === selected)!
              const state = npcState[selected] || {}
              return (
                <div>
                  <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
                    <h4>{(state.edited && state.edited.name) ? state.edited.name : (npc.name || npc.label)}</h4>
                    <div>
                      <button type="button" className="button" onClick={() => {
                        // enter edit mode, prefill
                        setEditMode(true)
                        setEditName((state.edited && state.edited.name) || npc.name || '')
                        setEditDesc((state.edited && state.edited.description) || (npc.description || ''))
                      }}>{editMode ? 'Editing' : 'Edit'}</button>
                       <button type="button" className="button" style={{marginLeft:8}} onClick={() => { const next = { ...npcState }; delete next[selected!]; setNpcState(next) }}>Clear State</button>
                       <button type="button" className="button" style={{marginLeft:8}} onClick={async () => {
                        // Export merged NPCs (base + edits)
                        try {
                          const res = await fetch('/bbs/npcs_full.json')
                          if (!res.ok) throw new Error('no base npcs')
                          const base = await res.json()
                          const merged = (Array.isArray(base) ? base : []).map((b: any) => {
                            const edits = npcState[b.label] && npcState[b.label].edited ? npcState[b.label].edited : null
                            if (edits) return { ...b, ...edits }
                            return b
                          })
                          const blob = new Blob([JSON.stringify(merged, null, 2)], { type: 'application/json' })
                          const url = URL.createObjectURL(blob)
                          const a = document.createElement('a')
                          a.href = url
                          a.download = `npcs-edited-${Date.now()}.json`
                          a.click()
                          URL.revokeObjectURL(url)
                          } catch (e) { if (addToast) addToast('Export failed'); }
                      }}>Export NPCs</button>
                      <label style={{marginLeft:8, display:'inline-flex', alignItems:'center'}}>
                        <input aria-label="Auto export edited NPCs" type="checkbox" checked={autoExportEnabled} onChange={(e) => {
                          const checked = e.target.checked
                          try {
                            const next = { ...npcState, _app: { ...(npcState._app || {}), autoExport: checked } }
                            setNpcState(next)
                          } catch (err) { console.warn(err) }
                          setAutoExportEnabled(checked)
                        }} />
                        <span style={{marginLeft:6}}>Auto-export</span>
                      </label>
                      <button type="button" className="button" style={{marginLeft:8}} onClick={async () => {
                        // Export only NPCs that have edits (merged with base) to a fixed filename so tooling can pick it up
                        try {
                          const res = await fetch('/bbs/npcs_full.json')
                          if (!res.ok) throw new Error('no base npcs')
                          const base = await res.json()
                          const baseMap: Record<string, any> = {}
                          if (Array.isArray(base)) base.forEach((b: any) => { baseMap[b.label] = b })
                          const out: any[] = []
                          // include edited merges for any base entries
                          for (const lbl of Object.keys(npcState)) {
                            const s = npcState[lbl] || {}
                            if (s.edited) {
                              const baseObj = baseMap[lbl] || { label: lbl }
                              out.push({ ...baseObj, ...s.edited })
                            }
                          }
                          if (out.length === 0) { if (addToast) addToast('No NPC edits to export'); return }
                          const blob = new Blob([JSON.stringify(out, null, 2)], { type: 'application/json' })
                          const url = URL.createObjectURL(blob)
                          const a = document.createElement('a')
                          a.href = url
                          a.download = `npcs-edited.json`
                          a.click()
                          URL.revokeObjectURL(url)
                          if (addToast) addToast('Exported npcs-edited.json')
                        } catch (e) { if (addToast) addToast('Export failed'); }
                      }}>Export npcs-edited.json</button>
                    </div>
                  </div>

                  {editMode ? (
                    <div style={{marginTop:8, marginBottom:8, padding:8, background:'#fff', border:'1px solid #eee'}}>
                      <div style={{marginBottom:8}}><label>Name</label><br/><input value={editName} onChange={(e) => setEditName(e.target.value)} style={{width:'100%'}} /></div>
                      <div style={{marginBottom:8}}><label>Description</label><br/><textarea value={editDesc} onChange={(e) => setEditDesc(e.target.value)} style={{width:'100%'}} rows={4} /></div>
                      <div>
                        <button className="button" onClick={() => {
                          const next = { ...npcState, [selected!]: { ...(npcState[selected!]||{}), edited: { name: editName, description: editDesc } } }
                          setNpcState(next)
                          setEditMode(false)
                        }}>Save</button>
                        <button className="button" style={{marginLeft:8}} onClick={() => setEditMode(false)}>Cancel</button>
                      </div>
                    </div>
                  ) : (
                    <div style={{marginBottom:8}}>{((state.edited && state.edited.description) ? state.edited.description : npc.description).split('\n').map((s,i) => <p key={i} style={{margin:4}}>{s}</p>)}</div>
                  )}

                  <div style={{marginBottom:8}}>
                    <button className="button" onClick={() => toggleFlag(selected, 'active')}>{state.active ? 'Deactivate' : 'Activate'}</button>
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      const res = talkToNpc(selected!, npcs, npcState)
                      setNpcState(res.nextState)
                      setLastDialog(res.text)
                    }}>Talk</button>
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      // Pop next queued dialog (if any)
                      const popped = popDialog(selected!, npcState)
                      setNpcState(popped.nextState)
                      if (popped.text) {
                        setLastDialog(popped.text)
                        if (addToast) addToast(popped.text)
                      } else {
                        if (addToast) addToast('No queued dialog')
                      }
                    }}>Pop Dialog</button>
                    <input style={{marginLeft:8, width:200}} placeholder="Queue dialog text" value={enqueueText} onChange={(e) => setEnqueueText(e.target.value)} />
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      if (!enqueueText) { if (addToast) addToast('Enter dialog text'); return }
                      const next = enqueueDialog(selected!, npcState, enqueueText)
                      setNpcState(next)
                      setEnqueueText('')
                      if (addToast) addToast('Queued dialog')
                    }}>Enqueue</button>
                    <button className="button" style={{marginLeft:8}} onClick={() => {
                      const r = ensureRestock(selected!, npcState, 0, detectShopItems(npc), 5)
                      setNpcState(r.nextState)
                      if (r.restocked) {
                        if (addToast) addToast('Restocked')
                      } else {
                        if (addToast) addToast('Not time to restock')
                      }
                    }}>Force Restock</button>
                      <button className="button" style={{marginLeft:8}} onClick={() => {
                      // initialize stock for this NPC if missing, using runtime edited override or generator default
                      const cur = npcState[selected!] || {}
                      const defaultItems = detectShopItems(npc)
                      if (!defaultItems || defaultItems.length === 0) { if (addToast) addToast('No shop items found'); return }
                      const editedQty = cur && cur.edited && typeof cur.edited.restockDefaultQty === 'number' ? Number(cur.edited.restockDefaultQty) : undefined
                      const defaultQty = typeof editedQty === 'number' ? editedQty : ((npc && typeof (npc as any).restockDefaultQty === 'number') ? Number((npc as any).restockDefaultQty) : 5)
                      const stock: Record<string, number> = {}
                      defaultItems.forEach(id => stock[String(id)] = (cur.stock && cur.stock[String(id)]) || defaultQty)
                      const next = { ...npcState, [selected!]: { ...cur, stock } }
                      setNpcState(next)
                      if (addToast) addToast('Initialized stock for NPC')
                    }}>Init Stock</button>
                  </div>

                  {lastDialog ? <div style={{marginBottom:8, padding:8, background:'#f7f7f7', borderRadius:4}}><strong>Dialog:</strong><div style={{marginTop:6}}>{lastDialog}</div></div> : null}
                  {state.dialogQueue && Array.isArray(state.dialogQueue) && state.dialogQueue.length > 0 ? (
                    <div style={{marginBottom:8, padding:8, background:'#fffbe6', borderRadius:4}}>
                      <strong>Queued Dialog ({state.dialogQueue.length})</strong>
                      <ul style={{marginTop:6}}>{state.dialogQueue.map((d:any,i:number)=>(
                        <li key={i} style={{display:'flex', alignItems:'center', marginBottom:6}}>
                          <span style={{flex:1}}>{d}</span>
                          <button className="button" style={{marginLeft:8}} onClick={() => {
                            const cur = npcState[selected!] || {}
                            const q = Array.isArray(cur.dialogQueue) ? [...cur.dialogQueue] : []
                            q.splice(i,1)
                            const next = { ...npcState, [selected!]: { ...cur, dialogQueue: q } }
                            setNpcState(next)
                            if (addToast) addToast('Removed queued dialog')
                          }}>Remove</button>
                        </li>
                      ))}</ul>
                    </div>
                  {/* Simple NPC Shop UI — detects numeric arrays and offers Buy/Sell controls */}
                  {(() => {
                    const shopIds = detectShopItems(npc)
                    if (!shopIds || shopIds.length === 0) return null
                    return (
                      <div style={{marginTop:8}}>
                        <h5>Shop</h5>
                        <ul style={{paddingLeft:12}}>
                          {shopIds.map(id => {
                            const name = ((gd.data && gd.data.items) && ((gd.data.items as any)[id] || (gd.data.items as any)[String(id)])) || (typeof id === 'number' ? `Item ${id}` : String(id))
                            const price = getPriceForItem(id, shopPrices, state)
                            const stock = state && state.stock ? Number(state.stock[String(id)] || 0) : undefined
                            return (
                              <li key={id} style={{marginBottom:6}}>
                                <span>{name} — {price}g{typeof stock === 'number' ? ` — stock: ${stock}` : ''}</span>
                                <button className="button" style={{marginLeft:8}} disabled={typeof stock === 'number' && stock <= 0} onClick={() => {
                                  const res = buyItem(selected!, id, price, gold, inventory as any, setNpcState, npcState)
                                  if (!res.ok) { if (addToast) addToast(res.message); return }
                                  if (setGold) setGold(res.gold)
                                  if (setInventory) setInventory(res.inventory)
                                  if (res.npcState) setNpcState(res.npcState)
                                  if (addToast) addToast(res.message || 'Bought 1')
                                }}>Buy</button>
                                <button className="button" style={{marginLeft:8}} onClick={() => {
                                  const res = sellItem(selected!, id, price, gold, inventory as any, setNpcState, npcState)
                                  if (!res.ok) { if (addToast) addToast(res.message); return }
                                  if (setGold) setGold(res.gold)
                                  if (setInventory) setInventory(res.inventory)
                                  if (res.npcState) setNpcState(res.npcState)
                                  if (addToast) addToast(res.message || 'Sold 1')
                                }}>Sell</button>
                                <input type="number" defaultValue={price} style={{width:80, marginLeft:8}} onBlur={(e) => {
                                  const v = Number(e.currentTarget.value)
                                  if (Number.isNaN(v)) return
                                  const next = { ...(npcState[selected!]||{}) }
                                  next.edited = next.edited || {}
                                  next.edited.prices = { ...(next.edited.prices || {}) }
                                  next.edited.prices[String(id)] = v
                                  setNpcState({ ...npcState, [selected!]: next })
                                }} />
                                {typeof stock === 'number' ? (
                                  <input type="number" defaultValue={stock} style={{width:80, marginLeft:8}} onBlur={(e) => {
                                    const v = Number(e.currentTarget.value)
                                    if (Number.isNaN(v)) return
                                    const cur = npcState[selected!] || {}
                                    const newStock = { ...(cur.stock || {}) }
                                    newStock[String(id)] = v
                                    const next = { ...npcState, [selected!]: { ...cur, stock: newStock } }
                                    setNpcState(next)
                                    if (addToast) addToast('Updated stock')
                                  }} />
                                ) : null}
                              </li>
                            )
                          })}
                        </ul>
                      </div>
                    )
                  })()}

                  <details style={{marginTop:8}}>
                    <summary>Edit Arrays (.byte/.word)</summary>
                    <div style={{marginTop:8}}>
                      <textarea style={{width:'100%', minHeight:120}} defaultValue={JSON.stringify({ bytes: npc.bytes, words: npc.words, unnamedBytes: npc.unnamedBytes, unnamedWords: npc.unnamedWords }, null, 2)} id="arrays_editor" />
                      <div style={{marginTop:8}}>
                        <button className="button" onClick={() => {
                          const t = (document.getElementById('arrays_editor') as HTMLTextAreaElement).value
                          try {
                            const parsed = JSON.parse(t)
                            const next = { ...(npcState[selected!]||{}) }
                            next.edited = next.edited || {}
                            next.edited.arrays = parsed
                            setNpcState({ ...npcState, [selected!]: next })
                            if (addToast) addToast('Saved arrays into npcState (edited.arrays)')
                            else if (addToast) addToast('Saved arrays into npcState (edited.arrays)')
                          } catch (e) { if (addToast) addToast('Invalid JSON'); }
                        }}>Save Arrays</button>
                      </div>
                    </div>
                  </details>

                  <details style={{marginTop:8}}>
                    <summary>Patrols & Scheduled Dialogs</summary>
                    <div style={{marginTop:8}}>
                      <div style={{marginBottom:8}}>
                        <label>Patrol Points</label>
                        <div style={{display:'flex', marginTop:6}}>
                          <input value={patrolPoint} onChange={(e) => setPatrolPoint(e.target.value)} placeholder="Location label" style={{flex:1}} />
                          <button className="button" style={{marginLeft:8}} onClick={() => {
                            if (!patrolPoint) { if (addToast) addToast('Enter patrol point'); return }
                            setPatrolPoints(p => [...p, patrolPoint])
                            setPatrolPoint('')
                          }}>Add</button>
                        </div>
                        <ul style={{marginTop:6}}>{patrolPoints.map((p,i) => (<li key={i} style={{marginBottom:6, display:'flex', alignItems:'center'}}><span style={{flex:1}}>{p}</span><button className="button" style={{marginLeft:8}} onClick={() => setPatrolPoints(ps => ps.filter((_,idx)=>idx!==i))}>Remove</button></li>))}</ul>
                        <div style={{marginTop:6}}>
                          <label>Patrol Interval (s)</label>
                          <input type="number" value={patrolInterval} onChange={e=>setPatrolInterval(Number(e.target.value)||30)} style={{width:120, marginLeft:8}} />
                          <button className="button" style={{marginLeft:8}} onClick={() => {
                            const cur = npcState[selected!] || {}
                            const next = { ...npcState, [selected!]: { ...cur, patrol: patrolPoints, nextPatrolAt: Date.now()+ (patrolInterval*1000), edited: { ...(cur.edited||{}), patrol: patrolPoints, patrolInterval: patrolInterval*1000 } } }
                            setNpcState(next)
                            if (addToast) addToast('Saved patrol')
                          }}>Save Patrol</button>
                        </div>
                      </div>

                      <div style={{marginTop:8}}>
                        <label>Schedule Dialog</label>
                        <div style={{display:'flex', marginTop:6}}>
                          <input value={schedText} onChange={(e) => setSchedText(e.target.value)} placeholder="Dialog text" style={{flex:1}} />
                          <input type="number" value={schedDelay} onChange={e => setSchedDelay(Number(e.target.value)||10)} style={{width:120, marginLeft:8}} />
                          <button className="button" style={{marginLeft:8}} onClick={() => {
                            if (!schedText) { if (addToast) addToast('Enter text'); return }
                            const next = scheduleDialog(selected!, npcState, schedDelay*1000, schedText)
                            setNpcState(next)
                            setSchedText('')
                            if (addToast) addToast('Scheduled dialog')
                          }}>Schedule</button>
                        </div>
                        {state.scheduledDialogs && Array.isArray(state.scheduledDialogs) && state.scheduledDialogs.length > 0 ? (
                          <ul style={{marginTop:8}}>
                            {state.scheduledDialogs.map((d:any,i:number)=> (
                              <li key={i} style={{display:'flex', alignItems:'center', marginBottom:6}}>
                                <div style={{flex:1}}>{d.text} <small style={{color:'#666', marginLeft:8}}>in {(Math.max(0, d.at - Date.now())/1000).toFixed(1)}s</small></div>
                                <button className="button" style={{marginLeft:8}} onClick={() => {
                                  const cur = npcState[selected!] || {}
                                  const list = Array.isArray(cur.scheduledDialogs) ? [...cur.scheduledDialogs] : []
                                  list.splice(i,1)
                                  const nxt = { ...npcState, [selected!]: { ...cur, scheduledDialogs: list } }
                                  setNpcState(nxt)
                                  if (addToast) addToast('Removed scheduled dialog')
                                }}>Remove</button>
                              </li>
                            ))}
                          </ul>
                        ) : null}
                      </div>
                    </div>
                  </details>

                  <div style={{marginTop:8}}>
                    <label>Import NPC edits (JSON): </label>
                    <input type="file" accept="application/json" onChange={(e) => {
                      const f = e.target.files && e.target.files[0]
                      if (!f) return
                      const r = new FileReader()
                      r.onload = () => {
                        try {
                          const parsed = JSON.parse(String(r.result))
                          if (Array.isArray(parsed)) {
                            const next = { ...npcState }
                            parsed.forEach((p: any) => { if (p.label) { next[p.label] = next[p.label] || {}; next[p.label].edited = { ...(next[p.label].edited||{}), ...(p.edited||{}) } } })
                            setNpcState(next)
                            if (addToast) addToast('Imported NPC edits')
                          } else {
                            if (addToast) addToast('Expected an array of NPC objects')
                          }
                        } catch (e) { if (addToast) addToast('Import failed'); else console.warn('Import failed') }
                      }
                      r.readAsText(f)
                    }} />
                  </div>
                  <details>
                    <summary>Raw Block</summary>
                    <pre style={{whiteSpace:'pre-wrap', fontSize:12}}>{npc.raw}</pre>
                  </details>
                  <details>
                    <summary>Arrays (.byte/.word)</summary>
                    <div>
                      <pre style={{whiteSpace:'pre-wrap', fontSize:12}}>{JSON.stringify({ bytes: npc.bytes, words: npc.words, unnamedBytes: npc.unnamedBytes, unnamedWords: npc.unnamedWords }, null, 2)}</pre>
                    </div>
                  </details>
                  <details>
                    <summary>Comments</summary>
                    <div>{npc.comments.map((c,i) => <div key={i}>{c}</div>)}</div>
                  </details>
                </div>
              )
            })()
          ) : (
            <div>Select an NPC to inspect</div>
          )}
        </div>
      </div>
    </div>
  )
}
