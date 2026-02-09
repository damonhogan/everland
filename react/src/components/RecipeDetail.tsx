import React from 'react'
import type { Recipe } from '../lib/crafting'

export default function RecipeDetail({ recipe, names }: { recipe: Recipe; names: Record<string,string> }) {
  if (!recipe) return null
  return (
    <div className="recipe" style={{marginTop:12}}>
      <h4>Recipe #{recipe.recipe_id} Details</h4>
      <div><strong>Output:</strong> {names[String(recipe.output_id)] ?? `#${recipe.output_id}`} x{recipe.output_qty}</div>
      <div><strong>Inputs:</strong> {recipe.input1_qty>0? `${names[String(recipe.input1_id)] ?? '#'+recipe.input1_id} x${recipe.input1_qty}` : 'None'}{recipe.input2_id!==255? `, ${names[String(recipe.input2_id)] ?? '#'+recipe.input2_id} x${recipe.input2_qty}` : ''}{recipe.input3_id!==255? `, ${names[String(recipe.input3_id)] ?? '#'+recipe.input3_id} x${recipe.input3_qty}` : ''}</div>
      <div><strong>Time:</strong> {recipe.time_ticks} ticks</div>
      <div><strong>Success:</strong> {recipe.success_rate}%</div>
      <div><strong>Skill requirement:</strong> {recipe.skill_req}</div>
      <div><strong>Discover flag:</strong> {recipe.discover_flag}</div>
    </div>
  )
}
