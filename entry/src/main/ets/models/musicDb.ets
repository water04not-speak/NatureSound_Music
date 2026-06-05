export interface MusicSongEntity {
  id: string
  title: string
  singer: string
  url: string
  cover: string
  lyric: string
  lyricOffsetMs: number
  isFavorite: number
  createTime: number
}

export interface MusicSongSeed {
  id: string
  title: string
  singer: string
  url: string
  cover: string
  lyric?: string
  lyricOffsetMs?: number
}
