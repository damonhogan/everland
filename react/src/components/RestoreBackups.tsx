import React, { useEffect, useState } from 'react'
import { listBackups, restoreBackupWithUndo } from '../lib/saveManager'

export default function RestoreBackups({ addToast }: { addToast?: (m:string)=>void }){
  const [keys, setKeys] = useState<string[]>([])
  const [preview, setPreview] = useState<string | null>(null)
  const [lastRestoreBackupKey, setLastRestoreBackupKey] = useState<string | null>(null)
  useEffect(()=> setKeys(listBackups()), [])
  function refresh(){ setKeys(listBackups()); setPreview(null) }
  return (
    <div style={{marginTop:12}}>
      <h3>Restore Backups</h3>
      <div>
        {keys.length === 0 ? <div>No backups found</div> : keys.map(k => (
          <div key={k} style={{marginBottom:6}}>
            <span style={{fontFamily:'monospace'}}>{k}</span>
            <button className="button" style={{marginLeft:8}} onClick={() => {
              try {
                const raw = localStorage.getItem(k)
                if (!raw) { if (addToast) addToast('No data'); return }
                const parsed = JSON.parse(raw)
                const summary = `v${parsed.version||1} @ ${new Date(parsed.timestamp||0).toLocaleString()} — inv:${(parsed.inventory||[]).length} quests:${(parsed.quests||[]).length}`
                setPreview(summary)
              } catch (e) { if (addToast) addToast('Preview failed') }
            }}>Preview</button>
            <button className="button" style={{marginLeft:8}} onClick={() => {
              const res = restoreBackupWithUndo(k)
              if (res.success) {
                setLastRestoreBackupKey(res.backupKey || null)
                if (addToast) addToast(`Restored ${k}`)
                refresh()
              } else { if (addToast) addToast('Restore failed') }
            }}>Restore</button>
          </div>
        ))}
      </div>
      {preview ? <div style={{marginTop:8}}><strong>Preview:</strong> <span style={{marginLeft:8}}>{preview}</span></div> : null}
      {lastRestoreBackupKey ? (
        <div style={{marginTop:8}}>
          <strong>Undo last restore:</strong>
          <button className="button" style={{marginLeft:8}} onClick={() => {
            if (!lastRestoreBackupKey) return
            const ok = restoreBackupWithUndo(lastRestoreBackupKey)
            if (ok.success) { if (addToast) addToast('Undo successful'); setLastRestoreBackupKey(null); refresh() }
            else { if (addToast) addToast('Undo failed') }
          }}>Undo</button>
        </div>
      ) : null}
    </div>
  )
}
