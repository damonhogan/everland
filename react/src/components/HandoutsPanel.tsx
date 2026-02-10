import React, { useEffect, useState } from 'react'

type Handout = { id: string; title: string; type: string; content_template: string; print_hint?: string }

export default function HandoutsPanel() {
  const [handouts, setHandouts] = useState<Handout[] | null>(null)

  useEffect(() => {
    fetch('/bbs/lore_scenes.json').then(r => r.json()).then(j => setHandouts(Array.isArray(j.handouts) ? j.handouts : null)).catch(() => setHandouts(null))
  }, [])

  if (!handouts) return (
    <div className="handouts-panel">
      <h3>Handouts</h3>
      <div style={{fontStyle:'italic', color:'#666'}}>No handouts found. Place `lore_scenes.json` into `react/public/bbs`.</div>
    </div>
  )

  const openPrintWindow = (title: string, html: string) => {
    const w = window.open('', '_blank', 'width=700,height=800')
    if (!w) { alert('Pop-up blocked; allow pop-ups to print handouts'); return }
    w.document.write(`<!doctype html><html><head><title>${title}</title><style>body{font-family:Georgia,serif;padding:24px} .scroll{border:1px dashed #333;padding:16px;border-radius:6px;background:#fff7ea}</style></head><body>${html}</body></html>`)
    w.document.close()
    w.focus()
    setTimeout(() => w.print(), 300)
  }

  const renderTemplate = (t: string) => {
    // basic placeholder replacement prompts the user for common keys
    let out = t
    const placeholders = t.match(/__\w+__/g) || []
    for (const ph of placeholders) {
      const key = ph.replace(/__/g, '')
      const val = prompt(`Enter value for ${key}`) || ''
      out = out.replace(new RegExp(ph, 'g'), val)
    }
    return out
  }

  return (
    <div className="handouts-panel">
      <h3>Handouts</h3>
      <div style={{display:'flex', flexDirection:'column', gap:8}}>
        {handouts.map(h => (
          <div key={h.id} style={{padding:8, border:'1px solid #eee', borderRadius:6, background:'#fff'}}>
            <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
              <div>
                <strong>{h.title}</strong>
                <div style={{fontSize:12,color:'#666'}}>{h.print_hint || ''}</div>
              </div>
              <div>
                <button className="button" onClick={() => {
                  const html = `<div class="scroll"><h2>${h.title}</h2><div style="white-space:pre-wrap;margin-top:12px">${renderTemplate(h.content_template)}</div></div>`
                  openPrintWindow(h.title, html)
                }}>Print</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
