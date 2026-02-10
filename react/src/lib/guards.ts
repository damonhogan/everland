import { pushEvent, loadEvents } from './events'

export type GuardReport = { id: string; time: number; location: string; description: string }

export function reportCrime(location: string, description: string): GuardReport {
  const e = pushEvent('crime', { actor: undefined, location, description })
  return { id: e.id, time: e.time, location: location, description }
}

export function sampleWitnesses(): GuardReport[] {
  const ev = loadEvents()
  return ev.filter((e:any) => e.type === 'crime').slice(0,10).map(e => ({ id: e.id, time: e.time, location: e.location || 'Unknown', description: e.description || '' }))
}

// Process new events and generate guard reports/actions. Returns generated GuardReports.
export function processNewEvents(): GuardReport[] {
  const ev = loadEvents()
  const lastKey = 'everland_events_last'
  let last = localStorage.getItem(lastKey) || null
  const reports: GuardReport[] = []
  for (let i = ev.length - 1; i >= 0; i--) {
    const e = ev[i]
    if (!e) continue
    if (last && e.id <= last) continue
    if (e.type === 'crime') {
      const rep = { id: e.id, time: e.time, location: e.location || 'Unknown', description: e.description || '' }
      reports.push(rep)
      // push a guard action event
      pushEvent('guard_action', { actor: 'guard', location: e.location, description: `Responding to ${e.id}` })
    }
    last = e.id
  }
  if (last) localStorage.setItem(lastKey, last)
  return reports
}
