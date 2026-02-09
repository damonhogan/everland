import React from 'react'
import type { InventoryItem } from '../lib/crafting'

export default function InventoryPanel({ inventory, setInventory }: { inventory: InventoryItem[]; setInventory: (i: InventoryItem[]) => void }) {
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

  return (
    <div style={{marginBottom:12}}>
      <h3>Inventory</h3>
      <div>
        {inventory.map((it, idx) => (
          <div key={idx} className="recipe">
            <div>Item #{it.itemId} — Qty: {it.qty}</div>
          </div>
        ))}
      </div>
      <div style={{marginTop:8}}>
        <button className="button" onClick={() => setInventory(prev => {
          const copy = prev.map(p => ({...p}))
          const e = copy.find(c => c.itemId===24)
          if (e) e.qty += 1; else copy.push({itemId:24, qty:1})
          return copy
        })}>Add Berry</button>
        <button className="button" style={{marginLeft:8}} onClick={() => setInventory([])}>Clear</button>
      </div>
    </div>
  )
}
