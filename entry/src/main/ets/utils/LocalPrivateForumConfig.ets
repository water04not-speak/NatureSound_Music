import common from '@ohos.app.ability.common'
import util from '@ohos.util'

const PRIVATE_FORUM_RAWFILE = 'local_forum.private.json'
const MAX_PRIVATE_MOMENTS = 100
const MAX_PRIVATE_COMMENTS = 50
const MAX_TEXT_LENGTH = 500

export interface LocalForumCommentSeed {
  id?: string
  author?: string
  avatar?: string
  content?: string
  like?: number
  createdAt?: number
}

export interface LocalForumSongSeed {
  cover?: string
}

export interface LocalForumMomentSeed {
  id?: string
  author?: string
  avatar?: string
  content?: string
  image?: string
  imageUrl?: string
  images?: string[]
  cover?: string
  songCover?: string
  song?: LocalForumSongSeed
  like?: number
  createdAt?: number
  songId?: string
  comments?: LocalForumCommentSeed[]
}

interface LocalForumJson {
  moments?: LocalForumMomentSeed[]
}

function decodeUtf8(bytes: Uint8Array): string {
  const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
  return decoder.decodeWithStream(bytes)
}

function safeText(value: string | undefined, maxLength: number): string {
  const text = typeof value === 'string' ? value.trim() : ''
  if (text.length > maxLength) {
    return text.substring(0, maxLength)
  }
  return text
}

function isAllowedImageValue(value: string): boolean {
  return value.length === 0
    || value.startsWith('app.media.')
    || value.startsWith('http://')
    || value.startsWith('https://')
    || value.startsWith('file://')
    || value.startsWith('private/')
    || value.startsWith('rawfile:')
    || value.startsWith('resource://RAWFILE/')
}

function firstAllowedImage(values: (string | undefined)[]): string {
  for (const value of values) {
    const text = safeText(value, 2048)
    if (text && isAllowedImageValue(text)) {
      return text
    }
  }
  return ''
}

function normalizeCount(value: number | undefined): number {
  if (typeof value !== 'number' || !isFinite(value)) {
    return 0
  }
  return Math.max(0, Math.round(value))
}

function normalizeTime(value: number | undefined, fallback: number): number {
  if (typeof value !== 'number' || !isFinite(value) || value <= 0) {
    return fallback
  }
  return Math.round(value)
}

function normalizeComment(seed: LocalForumCommentSeed, index: number, fallbackTime: number): LocalForumCommentSeed | undefined {
  const author = safeText(seed.author, 40)
  const content = safeText(seed.content, MAX_TEXT_LENGTH)
  const avatar = safeText(seed.avatar, 2048)
  if (!author || !content || !isAllowedImageValue(avatar)) {
    return undefined
  }
  return {
    id: safeText(seed.id, 80) || `private-comment-${fallbackTime}-${index}`,
    author,
    avatar,
    content,
    like: normalizeCount(seed.like),
    createdAt: normalizeTime(seed.createdAt, fallbackTime - index * 10 * 60 * 1000)
  }
}

function normalizeMoment(seed: LocalForumMomentSeed, index: number): LocalForumMomentSeed | undefined {
  const author = safeText(seed.author, 40)
  const content = safeText(seed.content, MAX_TEXT_LENGTH)
  const avatar = safeText(seed.avatar, 2048)
  const imageCandidates: (string | undefined)[] = [seed.image, seed.imageUrl]
  const rawImages = Array.isArray(seed.images) ? seed.images : []
  rawImages.forEach((image: string) => imageCandidates.push(image))
  const image = firstAllowedImage(imageCandidates)
  const songCover = firstAllowedImage([seed.songCover, seed.cover, seed.song?.cover])
  const now = Date.now()
  const createdAt = normalizeTime(seed.createdAt, now - index * 2 * 60 * 60 * 1000)
  if (!author || !content || !isAllowedImageValue(avatar)) {
    return undefined
  }
  const comments = (seed.comments ?? [])
    .slice(0, MAX_PRIVATE_COMMENTS)
    .map((comment: LocalForumCommentSeed, commentIndex: number) => normalizeComment(comment, commentIndex, createdAt))
    .filter((comment: LocalForumCommentSeed | undefined) => comment !== undefined) as LocalForumCommentSeed[]

  return {
    id: safeText(seed.id, 80) || `private-moment-${createdAt}-${index}`,
    author,
    avatar,
    content,
    image,
    imageUrl: image,
    images: image ? [image] : [],
    cover: songCover,
    songCover,
    song: songCover ? { cover: songCover } : undefined,
    like: normalizeCount(seed.like),
    createdAt,
    songId: safeText(seed.songId, 80),
    comments
  }
}

export async function loadLocalForumMomentSeeds(context: common.UIAbilityContext): Promise<LocalForumMomentSeed[]> {
  try {
    const raw = await context.resourceManager.getRawFileContent(PRIVATE_FORUM_RAWFILE)
    const parsed = JSON.parse(decodeUtf8(raw)) as LocalForumJson
    return (parsed.moments ?? [])
      .slice(0, MAX_PRIVATE_MOMENTS)
      .map((seed: LocalForumMomentSeed, index: number) => normalizeMoment(seed, index))
      .filter((seed: LocalForumMomentSeed | undefined) => seed !== undefined) as LocalForumMomentSeed[]
  } catch (_error) {
    return []
  }
}
