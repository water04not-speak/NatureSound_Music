import { SongItemType } from '../models/music'
import { MusicSongSeed } from '../models/musicDb'
import { findLyricBySongId } from './LyricDictionary'

interface HeritageSeed extends MusicSongSeed {
  regionId: string
}

const DEMO_AUDIO_BASE = 'https://example.invalid/nature-sound/legal-assets'

const heritageSeedsByRegion: Record<string, HeritageSeed[]> = {
  'yangtze-delta': [
    {
      id: 'demo-heritage-001',
      regionId: 'yangtze-delta',
      title: 'Jiangnan Texture Demo',
      singer: 'Licensed Resource Placeholder',
      url: `${DEMO_AUDIO_BASE}/jiangnan-texture.mp3`,
      cover: 'app.media.csj01'
    }
  ],
  'guangdong-hk-macao': [
    {
      id: 'demo-heritage-002',
      regionId: 'guangdong-hk-macao',
      title: 'Lingnan Rhythm Demo',
      singer: 'Licensed Resource Placeholder',
      url: `${DEMO_AUDIO_BASE}/lingnan-rhythm.mp3`,
      cover: 'app.media.yga01'
    }
  ],
  'chengdu-chongqing': [
    {
      id: 'demo-heritage-003',
      regionId: 'chengdu-chongqing',
      title: 'Bashu Soundscape Demo',
      singer: 'Licensed Resource Placeholder',
      url: `${DEMO_AUDIO_BASE}/bashu-soundscape.mp3`,
      cover: 'app.media.cy01'
    }
  ],
  'yangtze-mid': [
    {
      id: 'demo-heritage-004',
      regionId: 'yangtze-mid',
      title: 'Chu Tune Demo',
      singer: 'Licensed Resource Placeholder',
      url: `${DEMO_AUDIO_BASE}/chu-tune.mp3`,
      cover: 'app.media.cjzy01'
    }
  ]
}

const flatHeritageSeeds: HeritageSeed[] = []
Object.keys(heritageSeedsByRegion).forEach((regionId: string) => {
  const list = heritageSeedsByRegion[regionId]
  list.forEach((item: HeritageSeed) => flatHeritageSeeds.push(item))
})

export const heritageSeedSongs: MusicSongSeed[] = flatHeritageSeeds.map((item: HeritageSeed) => {
  const seed: MusicSongSeed = {
    id: item.id,
    title: item.title,
    singer: item.singer,
    url: item.url,
    cover: item.cover,
    lyric: findLyricBySongId(item.id),
    lyricOffsetMs: item.lyricOffsetMs ?? 0
  }
  return seed
})

export function getHeritageSongsByRegionId(regionId: string): SongItemType[] {
  const list = heritageSeedsByRegion[regionId] ?? []
  return list.map((item: HeritageSeed) => {
    const song: SongItemType = {
      id: item.id,
      name: item.title,
      author: item.singer,
      url: item.url,
      img: item.cover,
      title: item.title,
      singer: item.singer,
      cover: item.cover,
      lyric: findLyricBySongId(item.id),
      lyricOffsetMs: item.lyricOffsetMs ?? 0
    }
    return song
  })
}
