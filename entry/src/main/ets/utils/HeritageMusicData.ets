import common from '@ohos.app.ability.common'
import util from '@ohos.util'
import { SongItemType } from '../models/music'
import { MusicSongSeed } from '../models/musicDb'
import { findLyricBySongId } from './LyricDictionary'

interface HeritageSeed extends MusicSongSeed {
  regionId: string
}

interface LocalHeritageRegionJson {
  id: string
  songs?: MusicSongSeed[]
}

interface LocalHeritageJson {
  regions?: LocalHeritageRegionJson[]
}

const DEMO_AUDIO_BASE = 'https://example.invalid/nature-sound/legal-assets'
const PRIVATE_HERITAGE_RAWFILE = 'local_heritage.private.json'
const MAX_PRIVATE_REGION_SONGS = 100
const MAX_LYRIC_LENGTH = 50000
const MIN_LYRIC_OFFSET_MS = -30000
const MAX_LYRIC_OFFSET_MS = 120000

const heritageSeedsByRegion: Record<string, HeritageSeed[]> = {
  'yangtze-delta': [
    {
      id: 'demo-heritage-001',
      regionId: 'yangtze-delta',
      title: '江南丝竹片段',
      singer: '非遗声音示例',
      url: `${DEMO_AUDIO_BASE}/jiangnan-texture.mp3`,
      cover: 'app.media.csj01'
    },
    {
      id: 'demo-heritage-005',
      regionId: 'yangtze-delta',
      title: '昆曲水巷声景',
      singer: 'NatureSound Studio',
      url: `${DEMO_AUDIO_BASE}/kunqu-water-lane.mp3`,
      cover: 'app.media.csj02'
    }
  ],
  'guangdong-hk-macao': [
    {
      id: 'demo-heritage-002',
      regionId: 'guangdong-hk-macao',
      title: '粤韵醒狮鼓点',
      singer: '非遗声音示例',
      url: `${DEMO_AUDIO_BASE}/lingnan-rhythm.mp3`,
      cover: 'app.media.yga01'
    },
    {
      id: 'demo-heritage-006',
      regionId: 'guangdong-hk-macao',
      title: '南音街巷采样',
      singer: 'Public Demo Source',
      url: `${DEMO_AUDIO_BASE}/nanyin-street-sample.mp3`,
      cover: 'app.media.yga02'
    }
  ],
  'chengdu-chongqing': [
    {
      id: 'demo-heritage-003',
      regionId: 'chengdu-chongqing',
      title: '巴蜀鼓点采样',
      singer: '非遗声音示例',
      url: `${DEMO_AUDIO_BASE}/bashu-soundscape.mp3`,
      cover: 'app.media.cy01'
    },
    {
      id: 'demo-heritage-007',
      regionId: 'chengdu-chongqing',
      title: '川剧锣鼓声景',
      singer: 'NatureSound Studio',
      url: `${DEMO_AUDIO_BASE}/chuanju-gong-drum.mp3`,
      cover: 'app.media.cy02'
    }
  ],
  'yangtze-mid': [
    {
      id: 'demo-heritage-004',
      regionId: 'yangtze-mid',
      title: '楚调采风片段',
      singer: '非遗声音示例',
      url: `${DEMO_AUDIO_BASE}/chu-tune.mp3`,
      cover: 'app.media.cjzy01'
    },
    {
      id: 'demo-heritage-008',
      regionId: 'yangtze-mid',
      title: '湘音水岸声景',
      singer: 'Public Demo Source',
      url: `${DEMO_AUDIO_BASE}/xiang-river-soundscape.mp3`,
      cover: 'app.media.cjzy02'
    }
  ],
  'ancient-style': [
    {
      id: 'demo-heritage-009',
      regionId: 'ancient-style',
      title: '月下箫声',
      singer: 'NatureSound Studio',
      url: `${DEMO_AUDIO_BASE}/moonlit-xiao.mp3`,
      cover: 'app.media.gf01'
    },
    {
      id: 'demo-heritage-010',
      regionId: 'ancient-style',
      title: '山水入梦',
      singer: 'Public Demo Source',
      url: `${DEMO_AUDIO_BASE}/mountain-river-dream.mp3`,
      cover: 'app.media.gf02'
    }
  ],
  'modern-style': [
    {
      id: 'demo-heritage-011',
      regionId: 'modern-style',
      title: '城市雨声律动',
      singer: 'NatureSound Demo',
      url: `${DEMO_AUDIO_BASE}/city-rain-groove.mp3`,
      cover: 'app.media.xd01'
    },
    {
      id: 'demo-heritage-012',
      regionId: 'modern-style',
      title: '电子风铃片段',
      singer: 'Public Demo Source',
      url: `${DEMO_AUDIO_BASE}/electronic-wind-bell.mp3`,
      cover: 'app.media.xd02'
    }
  ],
  'wuxia-style': [
    {
      id: 'demo-heritage-013',
      regionId: 'wuxia-style',
      title: '竹林轻剑',
      singer: 'NatureSound Studio',
      url: `${DEMO_AUDIO_BASE}/bamboo-sword.mp3`,
      cover: 'app.media.wx01'
    },
    {
      id: 'demo-heritage-014',
      regionId: 'wuxia-style',
      title: '夜渡江湖',
      singer: 'Public Demo Source',
      url: `${DEMO_AUDIO_BASE}/night-river-journey.mp3`,
      cover: 'app.media.wx02'
    }
  ],
  'folk-style': [
    {
      id: 'demo-heritage-015',
      regionId: 'folk-style',
      title: '田埂晚风',
      singer: '非遗声音示例',
      url: `${DEMO_AUDIO_BASE}/field-evening-breeze.mp3`,
      cover: 'app.media.my01'
    },
    {
      id: 'demo-heritage-016',
      regionId: 'folk-style',
      title: '集市木吉他',
      singer: 'NatureSound Demo',
      url: `${DEMO_AUDIO_BASE}/market-guitar.mp3`,
      cover: 'app.media.my02'
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

function decodeUtf8(bytes: Uint8Array): string {
  const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
  return decoder.decodeWithStream(bytes)
}

function isAllowedAudioUrl(url: string): boolean {
  return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('file://')
}

function isAllowedCoverValue(cover: string): boolean {
  return cover.startsWith('app.media.') || cover.startsWith('http://') || cover.startsWith('https://') || cover.startsWith('file://')
}

function normalizeLyricOffset(value: number | undefined): number {
  const raw = typeof value === 'number' && isFinite(value) ? value : 0
  if (raw < MIN_LYRIC_OFFSET_MS) {
    return MIN_LYRIC_OFFSET_MS
  }
  if (raw > MAX_LYRIC_OFFSET_MS) {
    return MAX_LYRIC_OFFSET_MS
  }
  return Math.round(raw)
}

function isValidPrivateSong(seed: MusicSongSeed): boolean {
  const url = typeof seed?.url === 'string' ? seed.url.trim() : ''
  const cover = typeof seed?.cover === 'string' ? seed.cover.trim() : ''
  return !!seed
    && typeof seed.id === 'string'
    && seed.id.trim().length > 0
    && typeof seed.title === 'string'
    && seed.title.trim().length > 0
    && typeof seed.singer === 'string'
    && seed.singer.trim().length > 0
    && url.length > 0
    && cover.length > 0
    && url.length < 2048
    && cover.length < 2048
    && isAllowedAudioUrl(url)
    && isAllowedCoverValue(cover)
    && (!seed.lyric || seed.lyric.length <= MAX_LYRIC_LENGTH)
}

function toSongItem(seed: MusicSongSeed): SongItemType {
  const lyric = seed.lyric ?? findLyricBySongId(seed.id)
  return {
    id: seed.id.trim(),
    name: seed.title.trim(),
    author: seed.singer.trim(),
    url: seed.url.trim(),
    img: seed.cover.trim(),
    title: seed.title.trim(),
    singer: seed.singer.trim(),
    cover: seed.cover.trim(),
    lyric,
    lyricOffsetMs: normalizeLyricOffset(seed.lyricOffsetMs)
  }
}

export async function loadLocalHeritageSongsByRegion(context: common.UIAbilityContext): Promise<Record<string, SongItemType[]>> {
  try {
    const raw = await context.resourceManager.getRawFileContent(PRIVATE_HERITAGE_RAWFILE)
    const parsed = JSON.parse(decodeUtf8(raw)) as LocalHeritageJson
    const result: Record<string, SongItemType[]> = {}
    const regions = parsed.regions ?? []

    for (const region of regions) {
      if (!region || typeof region.id !== 'string' || region.id.trim().length === 0) {
        continue
      }
      const songs = (region.songs ?? [])
        .slice(0, MAX_PRIVATE_REGION_SONGS)
        .filter((seed: MusicSongSeed) => isValidPrivateSong(seed))
        .map((seed: MusicSongSeed) => toSongItem(seed))
      if (songs.length > 0) {
        result[region.id.trim()] = songs
      }
    }
    return result
  } catch (_error) {
    return {}
  }
}

export async function loadLocalHeritageSongsByRegionId(context: common.UIAbilityContext, regionId: string): Promise<SongItemType[]> {
  const all = await loadLocalHeritageSongsByRegion(context)
  return all[regionId] ?? []
}
