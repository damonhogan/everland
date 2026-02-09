import React, { useEffect, useState } from 'react'
import { craftExecute, Recipe } from '../lib/crafting'
import type { InventoryItem } from '../lib/crafting'
import RecipeDetail from './RecipeDetail'

// Recipe type moved to crafting lib

function parseByteLine(line: string): number[] {
  // remove inline comments after ';'
  const clean = line.split(';')[0]
  // extract numbers separated by commas
  const m = clean.match(/\.byte\s+(.+)/)
  if (!m) return []
  return m[1]
    .split(',')
    .map(s => s.trim())
    .filter(s => s.length > 0)
    .map(n => Number(n))
}

function parseRecipes(asmText: string): Recipe[] {
  const lines = asmText.split(/\r?\n/)
  const recipes: Recipe[] = []
  for (const line of lines) {
    if (line.trim().startsWith('.byte')) {
      const nums = parseByteLine(line)
      if (nums.length >= 15) {
        const r: Recipe = {
          recipe_id: nums[0],
          station_id: nums[1],
          output_id: nums[2],
          output_qty: nums[3],
          output_dur: nums[4],
          input1_id: nums[5],
          input1_qty: nums[6],
          input2_id: nums[7],
          input2_qty: nums[8],
          input3_id: nums[9],
          input3_qty: nums[10],
          time_ticks: nums[11],
          success_rate: nums[12],
          skill_req: nums[13],
          discover_flag: nums[14]
        }
        recipes.push(r)
      }
    }
  }
  return recipes
}

export default function CraftingBrowser({ stationId, stationName, inventory, setInventory }: { stationId: number; stationName: string; inventory: InventoryItem[]; setInventory: (i: InventoryItem[]) => void }) {
  const [recipes, setRecipes] = useState<Recipe[]>([])
  const [names, setNames] = useState<Record<string,string>>({})
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([
      fetch('/bbs/recipes.json').then(r => r.json()).catch(() => []),
      fetch('/bbs/item_map.json').then(r => r.json()).catch(() => ({}))
    ]).then(([recipesJson, itemMap]) => {
      setRecipes(Array.isArray(recipesJson) ? recipesJson : [])
      setNames(itemMap || {})
    }).catch(() => { setRecipes([]); setNames({}) })
  }, [])

  const stationRecipes = recipes.filter(r => r.station_id === stationId)
  const [selectedId, setSelectedId] = useState<number | null>(null)
  const selectedRecipe = selectedId === null ? null : recipes.find(r => r.recipe_id === selectedId) || null

  return (
    <div>
      <h2>{stationName} Recipes</h2>
      {message && <div className="recipe">{message}</div>}
      <div>
        {stationRecipes.length === 0 && <div>No recipes found for this station.</div>}
        {stationRecipes.map(r => (
          <div key={r.recipe_id} className="recipe" onClick={() => setSelectedId(r.recipe_id)} style={{cursor:'pointer'}}>
            <div><strong>Index:</strong> {r.recipe_id}</div>
            <div><strong>Output:</strong> {names[String(r.output_id)] ?? `#${r.output_id}`} x{r.output_qty}</div>
            <div><strong>Inputs:</strong> {r.input1_qty>0? `${names[String(r.input1_id)] ?? '#'+r.input1_id} x${r.input1_qty}` : 'None'}{r.input2_id!==255? `, ${names[String(r.input2_id)] ?? '#'+r.input2_id} x${r.input2_qty}` : ''}{r.input3_id!==255? `, ${names[String(r.input3_id)] ?? '#'+r.input3_id} x${r.input3_qty}` : ''}</div>
            <div><strong>Time:</strong> {r.time_ticks} ticks • <strong>Success:</strong> {r.success_rate}% • <strong>Skill req:</strong> {r.skill_req}</div>
            <div style={{marginTop:6}}>
              <button className="button" onClick={(e) => {
                e.stopPropagation()
                const res = craftExecute(r.recipe_id, recipes, inventory)
                setMessage(res.message)
                setInventory(res.inventory)
              }}>Craft</button>
            </div>
          </div>
        ))}
      </div>
      {selectedRecipe && <RecipeDetail recipe={selectedRecipe} names={names} />}
    </div>
  )
}
