import React, { useEffect, useState } from 'react'
import loadNpcs, { NPC } from '../lib/npcs'
import { talkToNpc, getPriceForItem, buyItem, sellItem, enqueueDialog, popDialog, ensureRestock } from '../lib/npcService'

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
  const [npcs, setNpcs] = useState<NPC[]>([])
  const [selected, setSelected] = useState<string | null>(null)
  const [lastDialog, setLastDialog] = useState<string | null>(null)
  const [editMode, setEditMode] = useState(false)
  const [enqueueText, setEnqueueText] = useState<string>('')
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

  useEffect(() => { loadNpcs().then(setNpcs) }, [])

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
      <div style={{display:'flex'}}>
        <ul style={{width:220, maxHeight:300, overflow:'auto', marginRight:12}}>
          {npcs.map(n => (
            <li key={n.label} style={{padding:6, borderBottom:'1px solid #ddd', cursor:'pointer'}} onClick={() => setSelected(n.label)}>
              <strong>{n.name || n.label}</strong>
              <div style={{fontSize:12, color:'#666'}}>{n.label}</div>
            </li>
          ))}
        </ul>
        <div style={{flex:1}}>
          {selected ? (
            (() => {
              const npc = npcs.find(x => x.label === selected)!
              const state = npcState[selected] || {}
              return (
                <div>
                  <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
                    <h4>{(state.edited && state.edited.name) ? state.edited.name : (npc.name || npc.label)}</h4>
                    <div>
                      <button className="button" onClick={() => {
                        // enter edit mode, prefill
                        setEditMode(true)
                        setEditName((state.edited && state.edited.name) || npc.name || '')
                        setEditDesc((state.edited && state.edited.description) || (npc.description || ''))
                      }}>{editMode ? 'Editing' : 'Edit'}</button>
                      <button className="button" style={{marginLeft:8}} onClick={() => { const next = { ...npcState }; delete next[selected!]; setNpcState(next) }}>Clear State</button>
                      <button className="button" style={{marginLeft:8}} onClick={async () => {
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
                      // initialize stock for this NPC if missing
                      const cur = npcState[selected!] || {}
                      const defaultItems = detectShopItems(npc)
                      if (!defaultItems || defaultItems.length === 0) { if (addToast) addToast('No shop items found'); return }
                      const stock: Record<string, number> = {}
                      defaultItems.forEach(id => stock[String(id)] = (cur.stock && cur.stock[String(id)]) || 5)
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
                  ) : null}

                  {/* Simple NPC Shop UI — detects numeric arrays and offers Buy button at default price */}
                  {(() => {
                    const shopIds = detectShopItems(npc)
                    if (!shopIds || shopIds.length === 0) return null
                    return (
                      <div style={{marginTop:8}}>
                        <h5>Shop</h5>
                        <ul style={{paddingLeft:12}}>
                          {shopIds.map(id => {
                            const name = (itemNames && (itemNames[id] || itemNames[String(id)])) || (typeof id === 'number' ? `Item ${id}` : String(id))
                            const price = getPriceForItem(id, shopPrices, state)
                            const stock = state && state.stock ? Number(state.stock[String(id)] || 0) : undefined
                            return (
                              <li key={id} style={{marginBottom:6}}>
                                <span>{name} — {price}g{typeof stock === 'number' ? ` — stock: ${stock}` : ''}</span>
                                <button className="button" style={{marginLeft:8}} disabled={typeof stock === 'number' && stock <= 0} onClick={() => {
                                  // buy one via helper
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
