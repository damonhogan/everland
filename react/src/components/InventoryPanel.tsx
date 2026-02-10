import React from 'react'
import type { InventoryItem } from '../lib/crafting'
import { useGameData } from '../context/GameDataContext'

export default function InventoryPanel({ inventory, setInventory }: { inventory: InventoryItem[]; setInventory: (i: InventoryItem[]) => void }) {
  const gd = useGameData()
  const itemsMap = gd.data?.items
  // load from localStorage on mount
  React.useEffect(() => {
    try {
      const raw = localStorage.getItem('everland_inventory')
      if (raw) {
        const parsed = JSON.parse(raw) as InventoryItem[]
        setInventory(parsed)
      }
    } catch {}
  }, [setInventory])

  // persist on change
  React.useEffect(() => {
    try { localStorage.setItem('everland_inventory', JSON.stringify(inventory)) } catch {}
  }, [inventory])

  const availableItems = itemsMap ? Object.entries(itemsMap) : []
  const defaultSelected = availableItems.length ? availableItems[0][0] : ''
  const [selectedId, setSelectedId] = React.useState<string>(defaultSelected)

  React.useEffect(() => {
    if (selectedId === '' && availableItems.length) setSelectedId(availableItems[0][0])
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [gd.status])

  function addItemById(id: number) {
    setInventory(prev => {
      const copy = prev.map(p => ({ ...p }))
      const found = copy.find(c => c.itemId === id)
      if (found) found.qty += 1
      else copy.push({ itemId: id, qty: 1 })
      return copy
    })
  }

  function changeQtyAt(idx: number, delta: number) {
    setInventory(prev => {
      const copy = prev.map(p => ({ ...p }))
      const slot = copy[idx]
      if (!slot) return prev
      slot.qty += delta
      if (slot.qty <= 0) copy.splice(idx, 1)
      return copy
    })
  }


  return (
    <div style={{marginBottom:12}}>
      <h3>Inventory</h3>
      <div>
        {inventory.map((it, idx) => {
          const key = String(it.itemId)
          const itemEntry = itemsMap ? (itemsMap as any)[key] : undefined
          const itemName = itemEntry
            ? (typeof itemEntry === 'string' ? itemEntry : itemEntry.name || `Item #${it.itemId}`)
            : `Item #${it.itemId}`
          return (
            <div key={idx} className="recipe" style={{display:'flex', alignItems:'center', justifyContent:'space-between'}}>
              <div>{itemName} — Qty: {it.qty}</div>
              <div>
                <button className="button" onClick={() => changeQtyAt(idx, 1)}>+</button>
                <button className="button" style={{marginLeft:6}} onClick={() => changeQtyAt(idx, -1)}>-</button>
                <button className="button" style={{marginLeft:6}} onClick={() => setInventory(prev => prev.filter((_,i) => i!==idx))}>Remove</button>
              </div>
            </div>
          )
        })}
      </div>
      <div style={{marginTop:8, display:'flex', alignItems:'center'}}>
        <select value={selectedId} onChange={e => setSelectedId(e.target.value)}>
          {availableItems.map(([id, value]) => {
            const name = typeof value === 'string' ? value : (value as any).name || `Item #${id}`
            return <option key={id} value={id}>{name} ({id})</option>
          })}
        </select>
        <button className="button" style={{marginLeft:8}} onClick={() => { if (selectedId) addItemById(Number(selectedId)) }}>Add</button>
        <button className="button" style={{marginLeft:8}} onClick={() => setInventory([])}>Clear</button>
      </div>
    </div>
  )
}
