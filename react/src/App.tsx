import React from 'react'
import CraftingBrowser from './components/CraftingBrowser'
import ManualViewer from './components/ManualViewer'
import LorePanel from './components/LorePanel'
import Toasts from './components/Toast'
import InventoryPanel, { InventoryItem } from './components/InventoryPanel'
import QuestPanel from './components/QuestPanel'
import { sampleQuests, unlockQuests } from './lib/quests'
import { completeAvailableQuests } from './lib/quests'
import TradePanel from './components/TradePanel'
import GuardPanel from './components/GuardPanel'
import { sampleWitnesses } from './lib/guards'
import NPCPanel from './components/NPCPanel'
import HighScores from './components/HighScores'
import MessageBoard from './components/MessageBoard'
import RoomCustomization from './components/RoomCustomization'
import ProfilePanel from './components/ProfilePanel'
import GhostBattles from './components/GhostBattles'
import FriendsPanel from './components/FriendsPanel'
import PrivateMessages from './components/PrivateMessages'
import SampleRooms from './components/SampleRooms'
import RestoreBackups from './components/RestoreBackups'
import { loadLocal } from './lib/saveManager'
import { useState, useRef, useEffect } from 'react'
import { loadLocal, saveLocal, importSave as importSaveManager, getLocalRaw, CURRENT_VERSION } from './lib/saveManager'
import useNpcScheduler from './lib/npcScheduler'
import { loadEvents } from './lib/events'
import { processEventTrigger } from './lib/quests'

export default function App() {
  const [inventory, setInventory] = useState<InventoryItem[]>([
    { itemId: 24, qty: 6 }, // berries
    { itemId: 6, qty: 3 },  // gems
    { itemId: 25, qty: 4 }, // meat
    { itemId: 21, qty: 10 }, // wood
    { itemId: 37, qty: 2 }  // flour (if present)
  ])
  const [quests, setQuests] = useState(sampleQuests())
  const [guardReports, setGuardReports] = useState(sampleWitnesses())
  const [gold, setGold] = useState<number>(100)
  const [npcState, setNpcState] = useState<Record<string, any>>({})
  const [toasts, setToasts] = useState<{ id: number; message: string }[]>([])

  function addToast(message: string) {
    const id = Date.now() + Math.floor(Math.random()*1000)
    setToasts(t => [...t, { id, message }])
    setTimeout(() => setToasts(t => t.filter(x => x.id !== id)), 6000)
  }

  function removeToast(id: number) { setToasts(t => t.filter(x => x.id !== id)) }
  const fileRef = useRef<HTMLInputElement | null>(null)
  const [itemNames, setItemNames] = useState<Record<string,string>>({})

  useEffect(() => {
    fetch('/bbs/item_map.json').then(r => r.json()).then(j => setItemNames(j || {})).catch(() => setItemNames({}))
    fetch('/bbs/quests.json').then(r => { if (r.ok) return r.json(); return null }).then(qj => { if (Array.isArray(qj)) setQuests(qj) }).catch(() => {})
    // attempt to auto-load a save on startup
    try {
      const s = loadLocal()
      if (s) {
        if (Array.isArray(s.inventory)) setInventory(s.inventory)
        if (Array.isArray(s.quests)) setQuests(unlockQuests(s.quests))
        if (Array.isArray(s.guardReports)) setGuardReports(s.guardReports)
        if (typeof s.gold === 'number') setGold(s.gold)
        if (s.npcState && typeof s.npcState === 'object') setNpcState(s.npcState)
        addToast(`Loaded local save (v${s.version || 1})`)
      }
    } catch (e) {}
  }, [])

  // auto-complete accepted quests when inventory changes
  useEffect(() => {
    if (!Array.isArray(quests) || quests.length === 0) return
    const { quests: updated, inventory: newInv, completed } = completeAvailableQuests(quests, inventory)
    if (completed.length > 0) {
      setQuests(updated)
      setInventory(newInv)
      addToast(`Completed quests: ${completed.join(', ')}`)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inventory])

  // run npc scheduler (restock + queued dialog)
  useNpcScheduler(npcState, setNpcState, addToast, 5000)

  // process incoming game events to trigger quests
  const lastEventRef = useRef<string | null>(null)
  useEffect(() => {
    const id = setInterval(() => {
      try {
        const evs = loadEvents()
        for (let i = evs.length - 1; i >= 0; i--) {
          const e = evs[i]
          if (!e) continue
          if (lastEventRef.current && e.id <= lastEventRef.current) continue
          const res = processEventTrigger(e, quests)
          if (res.accepted && res.accepted.length > 0) {
            setQuests(res.quests)
            addToast(`New quests available: ${res.accepted.join(', ')}`)
          }
          lastEventRef.current = e.id
        }
      } catch (e) {}
    }, 3000)
    return () => clearInterval(id)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [quests])

  function saveGame() {
    try {
      const wrapped = saveLocal({ inventory, quests, guardReports, gold, npcState })
      addToast(`Saved game (v${wrapped.version}) to localStorage`)
    } catch (e) { addToast('Save failed') }
  }

  function loadGame() {
    try {
      const parsed = loadLocal()
      if (!parsed) { addToast('No save found'); return }
      if (parsed) {
        if (Array.isArray(parsed.inventory)) setInventory(parsed.inventory)
        if (Array.isArray(parsed.quests)) setQuests(parsed.quests)
        if (Array.isArray(parsed.guardReports)) setGuardReports(parsed.guardReports)
        if (typeof parsed.gold === 'number') setGold(parsed.gold)
        if (parsed.npcState && typeof parsed.npcState === 'object') setNpcState(parsed.npcState)
      }
      addToast(`Loaded save (v${parsed.version || 1})`)
    } catch (e) { addToast('Load failed') }
  }

  function exportSave() {
    try {
      const currentRaw = getLocalRaw() || JSON.stringify({ version: CURRENT_VERSION, timestamp: Date.now(), inventory, quests, guardReports, npcState }, null, 2)
      const blob = new Blob([currentRaw], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `everland-save-${Date.now()}.json`
      a.click()
      URL.revokeObjectURL(url)
    } catch (e) { addToast('Export failed') }
  }

  function importSaveFile(file: File | null) {
    if (!file) return
    const reader = new FileReader()
    reader.onload = () => {
      try {
        const parsed = JSON.parse(String(reader.result))
        const r = importSaveManager(parsed)
        if (!r.success) { addToast(r.message); return }
        // apply imported
        const applied = loadLocal()
        if (applied) {
          if (Array.isArray(applied.inventory)) setInventory(applied.inventory)
          if (Array.isArray(applied.quests)) setQuests(unlockQuests(applied.quests))
          if (Array.isArray(applied.guardReports)) setGuardReports(applied.guardReports)
          if (typeof applied.gold === 'number') setGold(applied.gold)
          if (applied.npcState && typeof applied.npcState === 'object') setNpcState(applied.npcState)
        }
        addToast(r.message)
      } catch (e) { addToast('Import failed') }
    }
    reader.readAsText(file)
  }

  return (
    <div className="app">
      <header>
        <h1>Everland — BBS Port (React)</h1>
        <p>Initial port: manual viewer and crafting browser (apothecary)</p>
        <div style={{marginTop:8}}>
          <button className="button" onClick={saveGame}>Save</button>
          <button className="button" style={{marginLeft:8}} onClick={loadGame}>Load</button>
        </div>
      </header>
      <main>
        <section className="col">
          <ManualViewer />
          <LorePanel />
        </section>
        <section className="col">
          <InventoryPanel inventory={inventory} setInventory={setInventory} />
          <div style={{marginTop:8}}>
            <button className="button" onClick={saveGame}>Save</button>
            <button className="button" style={{marginLeft:8}} onClick={loadGame}>Load</button>
            <button className="button" style={{marginLeft:8}} onClick={exportSave}>Export</button>
            <button className="button" style={{marginLeft:8}} onClick={() => fileRef.current?.click()}>Import</button>
            <input ref={fileRef} type="file" accept="application/json" style={{display:'none'}} onChange={(e) => importSaveFile(e.target.files ? e.target.files[0] : null)} />
          </div>
          <CraftingBrowser stationId={4} stationName={"Kira's Apothecary"} inventory={inventory} setInventory={setInventory} />
          <QuestPanel quests={quests} setQuests={setQuests} inventory={inventory} setInventory={setInventory} names={itemNames} addToast={addToast} />
          <TradePanel gold={gold} setGold={setGold} inventory={inventory} setInventory={setInventory} addToast={addToast} />
          <GuardPanel reports={guardReports} setReports={setGuardReports} />
          <NPCPanel npcState={npcState} setNpcState={setNpcState} itemNames={itemNames} gold={gold} setGold={setGold} inventory={inventory} setInventory={setInventory} addToast={addToast} />
          <HighScores addToast={addToast} />
          <MessageBoard addToast={addToast} />
          <RoomCustomization addToast={addToast} />
          <ProfilePanel addToast={addToast} />
          <GhostBattles addToast={addToast} />
          <FriendsPanel addToast={addToast} />
          <PrivateMessages localName={(localStorage.getItem('everland_profile') ? JSON.parse(localStorage.getItem('everland_profile')||'{}').name : 'Player')} addToast={addToast} />
          <SampleRooms addToast={addToast} />
          <RestoreBackups addToast={addToast} />
        </section>
      </main>
      <Toasts toasts={toasts} remove={removeToast} />
    </div>
  )
}
