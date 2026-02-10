const fs = require('fs')
const path = require('path')
const { marked } = require('marked')

const root = path.resolve(__dirname, '..')
const bbsDir = path.resolve(root, '..', 'bbs')
const publicBbs = path.resolve(root, 'public', 'bbs')

if (!fs.existsSync(publicBbs)) fs.mkdirSync(publicBbs, { recursive: true })

// Read and convert item_names.json -> id->name map
try {
  const itemNamesRaw = fs.readFileSync(path.join(bbsDir, 'item_names.json'), 'utf8')
  let items = []
  try { items = JSON.parse(itemNamesRaw) } catch (e) { console.error('Failed to parse item_names.json', e); items = [] }
  const map = {}
  if (Array.isArray(items)) {
    for (const it of items) {
      if (it && typeof it.id !== 'undefined') map[String(it.id)] = String(it.name)
    }
  }
  fs.writeFileSync(path.join(publicBbs, 'item_map.json'), JSON.stringify(map, null, 2), 'utf8')
  console.log('Wrote item_map.json')
} catch (e) {
  console.error('item_names.json not found in bbs/, skipping item_map generation')
}

// Read and parse recipes.inc -> recipes.json
try {
  const recipesRaw = fs.readFileSync(path.join(bbsDir, 'recipes.inc'), 'utf8')
  const lines = recipesRaw.split(/\r?\n/)
  const recipes = []
  for (const line of lines) {
    const trimmed = line.trim()
    if (!trimmed.startsWith('.byte')) continue
    const after = trimmed.replace(/^\.byte\s+/, '')
    const withoutComment = after.split(';')[0]
    const parts = withoutComment.split(',').map(s => s.trim()).filter(s => s.length>0)
    const nums = parts.map(n => Number(n))
    if (nums.length >= 15) {
      const r = {
        recipe_id: nums[0], station_id: nums[1], output_id: nums[2], output_qty: nums[3], output_dur: nums[4],
        input1_id: nums[5], input1_qty: nums[6], input2_id: nums[7], input2_qty: nums[8], input3_id: nums[9], input3_qty: nums[10],
        time_ticks: nums[11], success_rate: nums[12], skill_req: nums[13], discover_flag: nums[14]
      }
      recipes.push(r)
    }
  }
  fs.writeFileSync(path.join(publicBbs, 'recipes.json'), JSON.stringify(recipes, null, 2), 'utf8')
  console.log('Wrote recipes.json')
} catch (e) {
  console.error('recipes.inc not found in bbs/, skipping recipes.json generation', e)
}

// Read quests from bbs/custom/everland_bbs.asm -> quests.json (if present)
try {
  const customAsmPath = path.join(bbsDir, 'custom', 'everland_bbs.asm')
  const asmRaw = fs.readFileSync(customAsmPath, 'utf8')
  const lines = asmRaw.split(/\r?\n/)
  // find quest_count
  let questCount = 0
  for (const line of lines) {
    const m = line.match(/^\s*quest_count:\s*\.byte\s+(\d+)/)

      // Deep NPC extraction: scan labels and capture adjacent text, arrays, comments, and directives
      try {
        const customAsmPath = path.join(bbsDir, 'custom', 'everland_bbs.asm')
        const asmRaw = fs.readFileSync(customAsmPath, 'utf8')
        const lines = asmRaw.split(/\r?\n/)

        // helper to parse numeric tokens (decimal, $hex, 0xhex, %binary)
        function parseNumToken(tok) {
          tok = tok.replace(/;.*$/, '').trim()
          if (!tok) return NaN
          if (/^\$[0-9A-Fa-f]+$/.test(tok)) return parseInt(tok.slice(1), 16)
          if (/^0x[0-9A-Fa-f]+$/i.test(tok)) return parseInt(tok, 16)
          if (/^%[01]+$/.test(tok)) return parseInt(tok.slice(1), 2)
          const n = Number(tok)
          return Number.isNaN(n) ? NaN : n
        }

        // collect label positions
        const labels = []
        for (let i = 0; i < lines.length; i++) {
          const lm = lines[i].match(/^\s*([A-Za-z0-9_]+):/) 
          if (lm) labels.push({ name: lm[1], index: i })
        }

        function findNextLabelIndex(startIdx) {
          for (let k = 0; k < labels.length; k++) if (labels[k].index > startIdx) return labels[k].index
          return lines.length
        }

        const deepNpcs = []
        for (let li = 0; li < labels.length; li++) {
          const lbl = labels[li]
          if (!lbl.name.startsWith('npc_')) continue
          const start = lbl.index
          const end = findNextLabelIndex(start)
          const blockLines = lines.slice(start, end)
          const raw = blockLines.join('\n')

          // gather comments immediately preceding the label (up to blank line)
          const comments = []
          for (let c = start - 1; c >= 0; c--) {
            const cl = lines[c].trim()
            if (cl === '') break
            if (cl.startsWith(';')) comments.unshift(cl.replace(/^;+\s?/, ''))
            else break
          }

          const texts = []
          const bytes = {}
          const unnamedBytes = []
          const words = {}
          const unnamedWords = []

          for (let k = 0; k < blockLines.length; k++) {
            const line = blockLines[k]
            // .text "..."
            let mt
            const textRe = /\.text\s+"([^"]+)"/g
            while ((mt = textRe.exec(line)) !== null) texts.push(mt[1])

            // labelled .byte  name: .byte 1,2,3
            const lb = line.match(/^\s*([A-Za-z0-9_]+):\s*\.byte\s+(.+)/)
            if (lb) {
              const vals = lb[2].split(',').map(s => parseNumToken(s)).filter(n => !Number.isNaN(n))
              bytes[lb[1]] = vals
              continue
            }
            const ub = line.match(/\.byte\s+(.+)/)
            if (ub) {
              const vals = ub[1].split(',').map(s => parseNumToken(s)).filter(n => !Number.isNaN(n))
              unnamedBytes.push(vals)
              continue
            }

            // .word
            const lw = line.match(/^\s*([A-Za-z0-9_]+):\s*\.word\s+(.+)/)
            if (lw) {
              const vals = lw[2].split(',').map(s => parseNumToken(s)).filter(n => !Number.isNaN(n))
              words[lw[1]] = vals
              continue
            }
            const uw = line.match(/\.word\s+(.+)/)
            if (uw) {
              const vals = uw[1].split(',').map(s => parseNumToken(s)).filter(n => !Number.isNaN(n))
              unnamedWords.push(vals)
              continue
            }
          }

          // try to find a friendly name: first .text or fallback to earlier simple name matches
          const name = (texts.length > 0 ? texts[0] : null)

          deepNpcs.push({
            label: lbl.name,
            name: name || '',
            description: texts.join('\n'),
            texts,
            bytes,
            unnamedBytes,
            words,
            unnamedWords,
            comments,
            raw,
            // generator defaults for runtime: restock quantity and a patrol template
            restockDefaultQty: 5,
            patrolTemplate: [],
            defaultPatrolIntervalMs: 30000
          })
        }

        if (deepNpcs.length > 0) {
          fs.writeFileSync(path.join(publicBbs, 'npcs_full.json'), JSON.stringify(deepNpcs, null, 2), 'utf8')
          console.log('Wrote npcs_full.json')
        }
      } catch (e) {
        console.error('npc deep extraction failed', e && e.message)
      }

      // Copy a local lore text file from the react folder into public/bbs if present
      try {
        const localLore = path.join(__dirname, '..', 'everland_lore.txt')
        if (fs.existsSync(localLore)) {
          fs.copyFileSync(localLore, path.join(publicBbs, 'everland_lore.txt'))
          console.log('Copied react/everland_lore.txt to public/bbs/everland_lore.txt')
        } else {
          // fallback: look for bbs/everland_lore.txt
          const bbsLore = path.join(bbsDir, 'everland_lore.txt')
          if (fs.existsSync(bbsLore)) {
            fs.copyFileSync(bbsLore, path.join(publicBbs, 'everland_lore.txt'))
            console.log('Copied bbs/everland_lore.txt to public/bbs/everland_lore.txt')
          }
        }
      } catch (e) {
        // ignore
      }
    if (m) { questCount = Number(m[1]); break }
  }
  if (questCount > 0) {
    const quests = []
    let idx = lines.findIndex(l => l.trim().startsWith('quest_names:'))
    if (idx >= 0) {
      idx++
      const names = []
      for (let i = 0; i < questCount && idx < lines.length; idx++) {
        const t = lines[idx].match(/\.text\s+"([^"]+)"/)
        if (t) { names.push(t[1].trim()); i++ }
      }
      // find targets, rewards, complete arrays
      const targetsLine = lines.find(l => l.trim().startsWith('quest_targets:')) || ''
      const rewardsLine = lines.find(l => l.trim().startsWith('quest_rewards:')) || ''
      const completeLine = lines.find(l => l.trim().startsWith('quest_complete:')) || ''
      const parseByteList = (ln) => ln && ln.split(':')[1] ? ln.split(':')[1].replace(/\.byte/, '').split(',').map(s => Number(s.trim())).filter(n => !Number.isNaN(n)) : []
      const targets = parseByteList(targetsLine)
      const rewards = parseByteList(rewardsLine)
      const complete = parseByteList(completeLine)

      // attempt to locate descriptive .text blocks for each quest by searching for the quest name nearby
      for (let i = 0; i < questCount; i++) {
        const title = names[i] || `Quest ${i}`
        let desc = ''
        // find an occurrence of the title in a .text line, then capture following contiguous .text blocks as the description
        const foundIndex = lines.findIndex(l => l.includes('.text') && l.includes(title))
        if (foundIndex >= 0) {
          const block = []
          // include the found line and subsequent .text lines until we hit a label (ends with ':') or a blank line
          for (let j = foundIndex; j < lines.length; j++) {
            const line = lines[j].trim()
            if (!line) break
            if (/^[^\s].*:$/.test(line)) break
            const m = line.match(/\.text\s+"([^"]+)"/)
            if (m) block.push(m[1].trim())
            else if (line.startsWith('.text') === false && j > foundIndex) break
          }
          desc = block.join('\n')
        } else {
          // fallback: try to capture the next block of .text lines after quest_names
          let start = lines.findIndex(l => l.trim().startsWith('quest_names:'))
          if (start >= 0) {
            start++
            const block = []
            for (let j = start; j < lines.length && block.length < 8; j++) {
              const m = lines[j].match(/\.text\s+"([^"]+)"/)
              if (m) block.push(m[1].trim())
            }
            desc = block[i] || ''
          }
        }
        quests.push({ id: i, title, description: desc, target: targets[i] || 0, reward_gold: rewards[i] || 0, complete: Boolean(complete[i]) })
      }
      fs.writeFileSync(path.join(publicBbs, 'quests.json'), JSON.stringify(quests, null, 2), 'utf8')
      console.log('Wrote quests.json')
    }
  }
} catch (e) {
  // no custom asm or parse failed
}

// Extract simple shop data: look for shop_item_prices and preceding .text names
try {
  const customAsmPath = path.join(bbsDir, 'custom', 'everland_bbs.asm')
  const asmRaw = fs.readFileSync(customAsmPath, 'utf8')
  const lines = asmRaw.split(/\r?\n/)
  const pricesLineIndex = lines.findIndex(l => l.trim().startsWith('shop_item_prices:'))
  if (pricesLineIndex >= 0) {
    const pricesLine = lines[pricesLineIndex]
    const pl = pricesLine.split(':')[1] ? pricesLine.split(':')[1].replace(/\.byte/, '').split(',').map(s => Number(s.trim())).filter(n => !Number.isNaN(n)) : []
    // collect preceding .text names up to pl.length
    const names = []
    let scan = pricesLineIndex - 1
    while (scan >= 0 && names.length < pl.length) {
      const m = lines[scan].match(/\.text\s+"([^"]+)"/)
      if (m) names.unshift(m[1].trim())
      scan--
    }
    const shop = pl.map((p, i) => ({ id: i, name: names[i] || `Item ${i}`, price: p }))
    fs.writeFileSync(path.join(publicBbs, 'shop.json'), JSON.stringify(shop, null, 2), 'utf8')
    console.log('Wrote shop.json')
  }
} catch (e) {
  // ignore
}

// Extract basic NPC names near labels starting with npc_ into npc.json
try {
  const customAsmPath = path.join(bbsDir, 'custom', 'everland_bbs.asm')
  const asmRaw = fs.readFileSync(customAsmPath, 'utf8')
  const lines = asmRaw.split(/\r?\n/)
  const npcs = []
  for (let i = 0; i < lines.length; i++) {
    const l = lines[i]
    const m = l.match(/^\s*(npc_[a-zA-Z0-9_]+):/) // label
    if (m) {
      // look ahead for a .text name
      for (let j = i + 1; j < i + 8 && j < lines.length; j++) {
        const t = lines[j].match(/\.text\s+"([^"]+)"/)
        if (t) { npcs.push({ label: m[1], name: t[1].trim() }); break }
      }
    }
  }
  if (npcs.length > 0) {
    fs.writeFileSync(path.join(publicBbs, 'npcs.json'), JSON.stringify(npcs, null, 2), 'utf8')
    console.log('Wrote npcs.json')
  }
} catch (e) {
  // ignore
}

// Render MANUAL.md -> MANUAL.html
try {
  const manualRaw = fs.readFileSync(path.join(bbsDir, 'MANUAL.md'), 'utf8')
  const html = marked(manualRaw)
  const wrapped = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Everland Manual</title><link rel="stylesheet" href="/src/styles.css"></head><body class="prose prose-invert">${html}</body></html>`
  fs.writeFileSync(path.join(publicBbs, 'MANUAL.html'), wrapped, 'utf8')
  console.log('Wrote MANUAL.html')
} catch (e) {
  console.error('MANUAL.md not found in bbs/, skipping MANUAL.html generation')
}

console.log('Asset conversion complete.')
