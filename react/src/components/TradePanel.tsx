import React, { useEffect, useState } from 'react'
import type { InventoryItem } from '../lib/crafting'

type ShopItem = { id: number; name: string; price: number }

export default function TradePanel({ gold, setGold, inventory, setInventory, addToast }: { gold: number; setGold: (g: number) => void; inventory: InventoryItem[]; setInventory: (i: InventoryItem[]) => void, addToast?: (m:string)=>void }) {
  const [shop, setShop] = useState<ShopItem[]>([])

  useEffect(() => {
    fetch('/bbs/shop.json').then(r => r.ok ? r.json() : []).then((j) => setShop(j || [])).catch(() => setShop([]))
  }, [])

  function buy(item: ShopItem) {
    if (gold < item.price) { if (addToast) addToast('Not enough gold'); else console.warn('Not enough gold'); return }
    setGold(gold - item.price)
    const copy = inventory.map(i => ({ ...i }))
    const ex = copy.find(c => c.itemId === item.id)
    if (ex) ex.qty += 1; else copy.push({ itemId: item.id, qty: 1 })
    setInventory(copy)
    if (addToast) addToast(`Bought ${item.name}`)
  }

  return (
    <div style={{marginTop:12}}>
      <h3>Marketplace — Gold: {gold}</h3>
      <div>
        {shop.map(s => (
          <div key={s.id} className="recipe">
            <div><strong>{s.name}</strong> — {s.price} gold</div>
            <div style={{marginTop:6}}><button className="button" onClick={() => buy(s)}>Buy</button></div>
          </div>
        ))}
      </div>
    </div>
  )
}
