const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')
const archiver = require('archiver')

// Ensure archiver is installed; this script assumes a Node environment where dev deps are present.

const root = path.resolve(__dirname, '..')
const outDir = path.join(root, 'dist')

function run(cmd) {
  console.log('>', cmd)
  execSync(cmd, { stdio: 'inherit', cwd: root })
}

async function zipDir(sourceDir, outPath) {
  const archive = archiver('zip', { zlib: { level: 9 }})
  const stream = fs.createWriteStream(outPath)

  return new Promise((resolve, reject) => {
    archive
      .directory(sourceDir, false)
      .on('error', err => reject(err))
      .pipe(stream)

    stream.on('close', () => resolve())
    archive.finalize()
  })
}

async function main() {
  try {
    console.log('Running build...')
    run('npm run build')
    if (!fs.existsSync(outDir)) {
      console.error('Build output not found:', outDir)
      process.exit(1)
    }
    const zipName = path.join(root, `everland-react-demo-${Date.now()}.zip`)
    console.log('Creating zip', zipName)
    await zipDir(outDir, zipName)
    console.log('Created demo zip at', zipName)
  } catch (e) {
    console.error('Failed:', e)
    process.exit(1)
  }
}

main()
