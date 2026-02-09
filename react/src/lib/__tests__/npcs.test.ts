import { describe, it, expect } from 'vitest'
import { parseNumToken } from '../npcs'

describe('parseNumToken', () => {
  it('parses decimal', () => {
    expect(parseNumToken('42')).toBe(42)
  })

  it('parses $hex', () => {
    expect(parseNumToken('$2A')).toBe(42)
  })

  it('parses 0xhex', () => {
    expect(parseNumToken('0x2a')).toBe(42)
  })

  it('parses %binary', () => {
    expect(parseNumToken('%101010')).toBe(42)
  })

  it('ignores comments and whitespace', () => {
    expect(parseNumToken('  $2A  ; comment')).toBe(42)
  })
})
