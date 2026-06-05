import common from '@ohos.app.ability.common'
import util from '@ohos.util'
import { MusicSongSeed } from '../models/musicDb'

const PRIVATE_MUSIC_RAWFILE = 'local_music.private.json'
const MAX_PRIVATE_SONGS = 200
const MAX_LYRIC_LENGTH = 50000

interface LocalPrivateMusicJson {
  replaceDefaultSeeds?: boolean
  songs?: MusicSongSeed[]
}

export interface LocalPrivateMusicConfig {
  replaceDefaultSeeds: boolean
  seeds: MusicSongSeed[]
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

function isValidSeed(seed: MusicSongSeed): boolean {
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

function normalizeSeed(seed: MusicSongSeed): MusicSongSeed {
  return {
    id: seed.id.trim(),
    title: seed.title.trim(),
    singer: seed.singer.trim(),
    url: seed.url.trim(),
    cover: seed.cover.trim(),
    lyric: seed.lyric
  }
}

/**
 * 读取本地私有曲库配置。
 *
 * 这个配置文件只用于开发者本机运行，不提交到公开仓库。
 * 找不到文件或内容不合法时，自动回退到公开版演示数据。
 */
export async function loadLocalPrivateMusicConfig(context: common.UIAbilityContext, fallbackSeeds: MusicSongSeed[]): Promise<LocalPrivateMusicConfig> {
  try {
    const raw = await context.resourceManager.getRawFileContent(PRIVATE_MUSIC_RAWFILE)
    const parsed = JSON.parse(decodeUtf8(raw)) as LocalPrivateMusicJson
    const rawSongs = (parsed.songs ?? []).slice(0, MAX_PRIVATE_SONGS)
    const seeds = rawSongs
      .filter((seed: MusicSongSeed) => isValidSeed(seed))
      .map((seed: MusicSongSeed) => normalizeSeed(seed))

    if (seeds.length === 0) {
      return {
        replaceDefaultSeeds: false,
        seeds: fallbackSeeds
      }
    }

    return {
      replaceDefaultSeeds: parsed.replaceDefaultSeeds !== false,
      seeds
    }
  } catch (_error) {
    return {
      replaceDefaultSeeds: false,
      seeds: fallbackSeeds
    }
  }
}
