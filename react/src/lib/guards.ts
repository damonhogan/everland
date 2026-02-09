import { pushEvent, loadEvents } from './events'

export type GuardReport = { id: string; time: number; location: string; description: string }

export function reportCrime(location: string, description: string): GuardReport {
  const e = pushEvent('crime', { actor: undefined, location, description })
  return { id: e.id, time: e.time, location: location, description }
}

export function sampleWitnesses(): GuardReport[] {
  const ev = loadEvents()
  // convert recent events of type 'crime' into GuardReport shape for display
  return ev.filter((e:any) => e.type === 'crime').slice(0,10).map(e => ({ id: e.id, time: e.time, location: e.location || 'Unknown', description: e.description || '' }))
}
