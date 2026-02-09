export type Recipe = {
  recipe_id: number
  station_id: number
  output_id: number
  output_qty: number
  output_dur: number
  input1_id: number
  input1_qty: number
  input2_id: number
  input2_qty: number
  input3_id: number
  input3_qty: number
  time_ticks: number
  success_rate: number
  skill_req: number
  discover_flag: number
}

export type InventoryItem = { itemId: number; qty: number; dur?: number }

function countInInventory(inv: InventoryItem[], itemId: number) {
  return inv.reduce((s, it) => (it.itemId === itemId ? s + it.qty : s), 0)
}

function consumeFromInventory(inv: InventoryItem[], itemId: number, amount: number): InventoryItem[] | null {
  // returns new inventory array or null if insufficient
  let need = amount
  const newInv = inv.map(i => ({ ...i }))
  for (let slot of newInv) {
    if (need <= 0) break
    if (slot.itemId === itemId) {
      const take = Math.min(slot.qty, need)
      slot.qty -= take
      need -= take
    }
  }
  if (need > 0) return null
  // filter out zero qty
  return newInv.filter(s => s.qty > 0)
}

export function craftExecute(recipeIdx: number | undefined, recipes: Recipe[], inventory: InventoryItem[]): { success: boolean; message: string; inventory: InventoryItem[] } {
  if (recipeIdx === undefined) return { success: false, message: 'No recipe selected', inventory }
  const recipe = recipes.find(r => r.recipe_id === recipeIdx)
  if (!recipe) return { success: false, message: 'Recipe not found', inventory }

  // prevalidate inputs
  const inputs: Array<{ id: number; qty: number }> = []
  if (recipe.input1_id !== 255) inputs.push({ id: recipe.input1_id, qty: recipe.input1_qty })
  if (recipe.input2_id !== 255) inputs.push({ id: recipe.input2_id, qty: recipe.input2_qty })
  if (recipe.input3_id !== 255) inputs.push({ id: recipe.input3_id, qty: recipe.input3_qty })

  for (const inp of inputs) {
    const have = countInInventory(inventory, inp.id)
    if (have < inp.qty) return { success: false, message: `Insufficient ${inp.id} (need ${inp.qty}, have ${have})`, inventory }
  }

  // consume in order: input1, input2, input3
  let workingInv = inventory.map(i => ({ ...i }))
  for (const inp of inputs) {
    const consumed = consumeFromInventory(workingInv, inp.id, inp.qty)
    if (!consumed) return { success: false, message: `Consume failed for ${inp.id}`, inventory }
    workingInv = consumed
  }

  // success chance
  const roll = Math.random() * 100
  if (roll > recipe.success_rate) {
    return { success: false, message: 'Craft failed (bad roll)', inventory: workingInv }
  }

  // add output
  const outId = recipe.output_id
  const outQty = recipe.output_qty
  const outDur = recipe.output_dur
  const outSlot = workingInv.find(s => s.itemId === outId && (outDur == null || s.dur == null || s.dur === outDur))
  if (outSlot) {
    outSlot.qty += outQty
  } else {
    const newItem: InventoryItem = { itemId: outId, qty: outQty }
    if (outDur && outDur > 0) newItem.dur = outDur
    workingInv.push(newItem)
  }

  return { success: true, message: `Crafted ${outQty}x ${outId}`, inventory: workingInv }
}
