import React, { useEffect, useState } from 'react'
import { marked } from 'marked'

export default function ManualViewer() {
  const [md, setMd] = useState<string>('')
  const [html, setHtml] = useState<string | null>(null)

  useEffect(() => {
    // prefer pre-rendered HTML if generated
    fetch('/bbs/MANUAL.html').then(r => {
      if (r.ok) return r.text().then(t => setHtml(t))
      return fetch('/bbs/MANUAL.md').then(r2 => r2.text()).then(t => setMd(t))
    }).catch(() => setMd('# Manual not found\nRun `npm run generate:assets` to produce MANUAL.html'))
  }, [])

  return (
    <div>
      <h2>Manual</h2>
      {html ? <div dangerouslySetInnerHTML={{ __html: html }} /> : <div className="manual" dangerouslySetInnerHTML={{ __html: marked(md) }} />}
    </div>
  )
}
