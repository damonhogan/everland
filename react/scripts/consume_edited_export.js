const fs = require('fs')
const path = require('path')

// Usage: node scripts/consume_edited_export.js [input.json]
// If input file exists, write merged edits to public/bbs/npcs-edited.json for CI tooling.

const root = path.resolve(__dirname, '..')
const publicBbs = path.join(root, 'public', 'bbs')
const input = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, 'npcs_edits_input.json')

function main() {
  if (!fs.existsSync(input)) {
    console.log('No edits input file found at', input)
    process.exit(0)
  }
  try {
    const raw = fs.readFileSync(input, 'utf8')
    const parsed = JSON.parse(raw)
    if (!Array.isArray(parsed)) {
      console.error('Expected an array of NPC edit objects in', input)
      process.exit(1)
    }
    if (!fs.existsSync(publicBbs)) fs.mkdirSync(publicBbs, { recursive: true })
    const outPath = path.join(publicBbs, 'npcs-edited.json')
    fs.writeFileSync(outPath, JSON.stringify(parsed, null, 2), 'utf8')
    console.log('Wrote', outPath)
  } catch (e) {
    console.error('Failed to write edits:', e)
    process.exit(1)
  }
}

main()
