class AudioManager {
  private audioMap: Record<string, HTMLAudioElement | null> = {}
  private volume = 0.6

  setVolume(v: number) {
    this.volume = Math.max(0, Math.min(1, v))
    for (const k of Object.keys(this.audioMap)) {
      const a = this.audioMap[k]
      if (a) a.volume = this.volume
    }
  }

  async ensureTrack(id: string) {
    if (this.audioMap[id]) return this.audioMap[id]
    try {
      const res = await fetch('/bbs/audio_assets.json')
      if (!res.ok) throw new Error('no assets')
      const j = await res.json()
      const track = (j.tracks || []).find((t: any) => t.id === id)
      if (!track || !track.src) throw new Error('track not found')
      const a = new Audio(track.src)
      a.loop = true
      a.volume = this.volume
      this.audioMap[id] = a
      return a
    } catch (e) {
      this.audioMap[id] = null
      return null
    }
  }

  async play(id: string) {
    const a = await this.ensureTrack(id)
    try { if (a) await a.play() } catch (e) {}
  }

  stop() {
    for (const k of Object.keys(this.audioMap)) {
      const a = this.audioMap[k]
      if (a) {
        try { a.pause(); a.currentTime = 0 } catch (e) {}
      }
    }
  }
}

export default new AudioManager()
