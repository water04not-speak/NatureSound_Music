import common from '@ohos.app.ability.common'
import util from '@ohos.util'
import { MusicSongSeed } from '../models/musicDb'

const PRIVATE_MUSIC_RAWFILE = 'local_music.private.json'

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

function isValidSeed(seed: MusicSongSeed): boolean {
  return !!seed
    && typeof seed.id === 'string'
    && seed.id.trim().length > 0
    && typeof seed.title === 'string'
    && seed.title.trim().length > 0
    && typeof seed.singer === 'string'
    && seed.singer.trim().length > 0
    && typeof seed.url === 'string'
    && seed.url.trim().length > 0
    && typeof seed.cover === 'string'
    && seed.cover.trim().length > 0
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

export async function loadLocalPrivateMusicConfig(context: common.UIAbilityContext, fallbackSeeds: MusicSongSeed[]): Promise<LocalPrivateMusicConfig> {
  try {
    const raw = await context.resourceManager.getRawFileContent(PRIVATE_MUSIC_RAWFILE)
    const parsed = JSON.parse(decodeUtf8(raw)) as LocalPrivateMusicJson
    const rawSongs = parsed.songs ?? []
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
