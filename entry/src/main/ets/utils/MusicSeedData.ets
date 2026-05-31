import { MusicSongSeed } from '../models/musicDb'
import { findLyricBySongId } from './LyricDictionary'
import { heritageSeedSongs } from './HeritageMusicData'

const DEMO_AUDIO_BASE = 'https://example.invalid/nature-sound/legal-assets'

export const defaultMusicSeeds: MusicSongSeed[] = [
  {
    id: 'demo-ambient-001',
    title: 'Demo Ambient Stream',
    singer: 'NatureSound Demo',
    url: `${DEMO_AUDIO_BASE}/ambient-stream.mp3`,
    cover: 'app.media.RecomMusic01'
  },
  {
    id: 'demo-ambient-002',
    title: 'Demo Rain Texture',
    singer: 'NatureSound Demo',
    url: `${DEMO_AUDIO_BASE}/rain-texture.mp3`,
    cover: 'app.media.RecomMusic02'
  },
  {
    id: 'demo-playlist-001',
    title: 'Demo Playlist Item',
    singer: 'Portfolio Placeholder',
    url: `${DEMO_AUDIO_BASE}/playlist-item.mp3`,
    cover: 'app.media.RecomMusic03'
  },
  {
    id: 'demo-playlist-002',
    title: 'Demo Local Playback',
    singer: 'Portfolio Placeholder',
    url: `${DEMO_AUDIO_BASE}/local-playback.mp3`,
    cover: 'app.media.RecomMusic04'
  }
]

for (const seed of heritageSeedSongs) {
  defaultMusicSeeds.push(seed)
}

/**
 * This class is the song-card structure used directly by pages.
 */
export class SongItem {
  img: string
  name: string
  author: string
  url: string
  id: string
  lyric?: string

  constructor(img: string, name: string, author: string, url: string, id: string, lyric?: string) {
    this.img = img
    this.name = name
    this.author = author
    this.url = url
    this.id = id
    this.lyric = lyric
  }
}

export function getDefaultSongItems(): SongItem[] {
  return defaultMusicSeeds.map((s: MusicSongSeed) => {
    const resolvedLyric = findLyricBySongId(s.id)
    return new SongItem(s.cover, s.title, s.singer, s.url, s.id, resolvedLyric)
  })
}
