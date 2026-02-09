import { describe, it, expect } from 'vitest'
import fs from 'fs'
import path from 'path'
import { execSync } from 'child_process'

describe('generated assets exist', () => {
  // Run the asset generator first to ensure files are present
  try {
    execSync('node ./tools/convert_assets.js', { stdio: 'ignore' })
  } catch (e) {
    // if generator fails, tests will still check for files and fail explicitly
  }
  it('public/bbs/npcs_full.json exists', () => {
    const p = path.join(process.cwd(), 'public', 'bbs', 'npcs_full.json')
    expect(fs.existsSync(p)).toBe(true)
  })

  it('public/bbs/quests.json exists', () => {
    const p = path.join(process.cwd(), 'public', 'bbs', 'quests.json')
    expect(fs.existsSync(p)).toBe(true)
  })

  it('public/bbs/recipes.json exists', () => {
    const p = path.join(process.cwd(), 'public', 'bbs', 'recipes.json')
    expect(fs.existsSync(p)).toBe(true)
  })
})
