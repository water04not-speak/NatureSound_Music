import common from '@ohos.app.ability.common'
import dataPreferences from '@ohos.data.preferences'
import { GlobalMusic } from '../models/globalMusic'
import { SongItemType } from '../models/music'

interface PersistedPlaybackSnapshot {
  id: string
  url: string
  time: number
  duration: number
  playIndex: number
  playMode: 'auto' | 'random' | 'repeat'
  playList: SongItemType[]
}

/**
 * 【通俗解释】这里像“播放器断点存档点”。
 * 每次播放状态变化都写一份轻量快照；下次启动时再读回来，
 * 让用户能回到上次那首歌和播放队列，而不是每次都从零开始。
 */
class PlaybackSnapshotStore {
  private static readonly STORE_NAME: string = 'playbackSnapshotStore'
  private static readonly SNAPSHOT_KEY: string = 'playback_snapshot_v1'
  private prefs: dataPreferences.Preferences | null = null
  private lastSerialized: string = ''

  async init(context: common.UIAbilityContext): Promise<void> {
    if (!this.prefs) {
      this.prefs = await dataPreferences.getPreferences(context, PlaybackSnapshotStore.STORE_NAME)
    }
  }

  private sanitizeSong(song: SongItemType): SongItemType {
    return {
      img: song.img,
      name: song.name,
      author: song.author,
      url: song.url,
      id: song.id,
      title: song.title,
      singer: song.singer,
      cover: song.cover,
      lyric: song.lyric,
      isFavorite: song.isFavorite,
      createTime: song.createTime,
      lyrics: song.lyrics,
      lyricLines: song.lyricLines
    }
  }

  private buildSnapshot(playState: GlobalMusic): PersistedPlaybackSnapshot {
    const list = playState.playList.slice(0, 300).map((song: SongItemType) => this.sanitizeSong(song))
    const boundedIndex = Math.max(0, Math.min(playState.playIndex, Math.max(0, list.length - 1)))
    return {
      id: playState.id,
      url: playState.url,
      time: Math.max(0, playState.time),
      duration: Math.max(0, playState.duration),
      playIndex: boundedIndex,
      playMode: playState.playMode,
      playList: list
    }
  }

  async save(playState: GlobalMusic): Promise<void> {
    if (!this.prefs) {
      return
    }
    const snapshot = this.buildSnapshot(playState)
    const serialized = JSON.stringify(snapshot)
    if (serialized === this.lastSerialized) {
      return
    }
    await this.prefs.put(PlaybackSnapshotStore.SNAPSHOT_KEY, serialized)
    await this.prefs.flush()
    this.lastSerialized = serialized
  }

  async restoreTo(target: GlobalMusic): Promise<boolean> {
    if (!this.prefs) {
      return false
    }

    const raw = await this.prefs.get(PlaybackSnapshotStore.SNAPSHOT_KEY, '') as string
    if (!raw || raw.trim().length === 0) {
      return false
    }

    try {
      const parsed = JSON.parse(raw) as PersistedPlaybackSnapshot
      if (!parsed || !Array.isArray(parsed.playList) || parsed.playList.length === 0) {
        return false
      }

      const restoredList = parsed.playList.map((song: SongItemType) => this.sanitizeSong(song))
      const restoredIndex = Math.max(0, Math.min(parsed.playIndex ?? 0, restoredList.length - 1))
      const current = restoredList[restoredIndex]

      target.playList = restoredList
      target.playIndex = restoredIndex
      target.playMode = parsed.playMode ?? 'auto'
      target.time = Math.max(0, parsed.time ?? 0)
      target.duration = Math.max(0, parsed.duration ?? 0)
      target.id = current.id
      target.url = current.url
      target.img = current.img
      target.name = current.name
      target.author = current.author
      target.lyric = current.lyric
      target.isFavorite = current.isFavorite
      target.lyrics = current.lyrics
      target.lyricLines = current.lyricLines
      // 启动恢复只恢复上下文，不做自动播放，避免应用被动起播。
      target.isPlay = false

      this.lastSerialized = raw
      return true
    } catch (_error) {
      return false
    }
  }
}

export const playbackSnapshotStore: PlaybackSnapshotStore = new PlaybackSnapshotStore()
