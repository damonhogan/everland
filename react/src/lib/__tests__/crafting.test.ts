import { describe, it, expect, beforeEach } from 'vitest'
import { craftExecute, Recipe, InventoryItem } from '../crafting'

describe('craftExecute', () => {
  const recipes: Recipe[] = [{
    recipe_id: 1,
    station_id: 4,
    output_id: 50,
    output_qty: 1,
    output_dur: 0,
    input1_id: 24,
    input1_qty: 2,
    input2_id: 255,
    input2_qty: 0,
    input3_id: 255,
    input3_qty: 0,
    time_ticks: 10,
    success_rate: 100,
    skill_req: 0,
    discover_flag: 0
  }]

  it('consumes inputs and adds output on success', () => {
    const inv: InventoryItem[] = [{ itemId: 24, qty: 3 }]
    // force RNG to 0 by monkeypatching Math.random
    const orig = Math.random
    Math.random = () => 0
    const res = craftExecute(1, recipes, inv)
    Math.random = orig
    expect(res.success).toBe(true)
    expect(res.inventory.find(i => i.itemId === 24)?.qty).toBe(1)
    expect(res.inventory.find(i => i.itemId === 50)?.qty).toBe(1)
  })

  it('fails when insufficient inputs', () => {
    const inv: InventoryItem[] = [{ itemId: 24, qty: 1 }]
    const res = craftExecute(1, recipes, inv)
    expect(res.success).toBe(false)
  })
})
