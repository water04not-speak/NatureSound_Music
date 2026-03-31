import { MusicSongSeed } from '../models/musicDb'

export function buildSearchHintPool(seeds: MusicSongSeed[]): string[] {
  const pool = seeds
    .map((seed: MusicSongSeed) => seed.title.trim())
    .filter((title: string) => title.length > 0)

  return Array.from(new Set(pool))
}

export function pickRandomSearchHint(hints: string[], fallback: string): string {
  if (hints.length === 0) {
    return fallback
  }

  const randomIndex = Math.floor(Math.random() * hints.length)
  return hints[randomIndex]
}