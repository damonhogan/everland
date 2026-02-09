import React from 'react'

export type Toast = { id: number; message: string }

export default function Toasts({ toasts, remove }: { toasts: Toast[]; remove: (id: number) => void }) {
  return (
    <div style={{position:'fixed', right:12, top:12, zIndex:999}}>
      {toasts.map(t => (
        <div key={t.id} style={{background:'#222', color:'#fff', padding:'8px 12px', marginBottom:8, borderRadius:6, minWidth:200}}>
          <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
            <div>{t.message}</div>
            <button style={{marginLeft:8, background:'transparent', border:0, color:'#fff', cursor:'pointer'}} onClick={() => remove(t.id)}>×</button>
          </div>
        </div>
      ))}
    </div>
  )
}
