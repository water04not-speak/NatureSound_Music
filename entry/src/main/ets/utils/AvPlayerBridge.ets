import { media } from '@kit.MediaKit'
import { GlobalMusic } from '../models/globalMusic'
import { SongItemType } from '../models/music'
import { sessionManager } from './AvSessionManager'
import { currentSong as sharedCurrentSong } from './PlaybackState'
import { downloadManager } from './DownloadManager'
import { playbackSnapshotStore } from './PlaybackSnapshotStore'

/**
 * AvPlayerBridge 类
 * 提供了与媒体播放器（AvPlayer）的桥接接口，用于初始化播放器、加载并在不同歌曲之间切换。
 */
class AvPlayerBridge {
  player: media.AVPlayer | null = null
  currentSong: GlobalMusic = sharedCurrentSong
  private lastStateUpdateTime: number = 0
  private canFallbackToRemote: boolean = false
  private remoteFallbackTried: boolean = false
  private remoteFallbackUrl: string = ''
  private currentPlayerUrl: string = ''
  private lastSnapshotAt: number = 0

  /**
   * 【通俗解释】很多曲库外链是 http，部分设备/网络策略会拦截明文流。
   * 这里统一改成 https，尽量减少“明明有歌却播不出来”的情况。
   */
  private normalizeStreamUrl(url: string): string {
    if (!url) {
      return ''
    }
    if (url.includes('id=37988002')) {
      return 'https://music.163.com/song/media/outer/url?id=3358682441.mp3'
    }
    if (url.includes('id=3329325495')) {
      return 'https://music.163.com/song/media/outer/url?id=2026544587.mp3'
    }
    if (url.startsWith('http://music.163.com/')) {
      return 'https://' + url.substring('http://'.length)
    }
    return url
  }

  /**
   * 初始化媒体播放器
   * @returns Promise<void>
   */
  async init(): Promise<void> {
    if (!this.player) {
      try {
        this.player = await media.createAVPlayer()
      } catch (error) {
        console.error('[AvPlayerBridge] 创建播放器失败:', error)
        return
      }
    }

    // 监听播放器状态，驱动自动播放、切歌和错误回收
    this.player.on('stateChange', (state) => {
      console.info(`[AvPlayerBridge] 播放器状态变化: ${state}`)
      if (state === 'initialized') {
        this.player?.prepare()
      } else if (state === 'prepared') {
        this.player?.play()
        this.currentSong.isPlay = true
        void playbackSnapshotStore.save(this.currentSong)
      } else if (state === 'completed') {
        this.nextPlay(true)
      } else if (state === 'released') {
        this.currentPlayerUrl = ''
        this.currentSong.reset()
      } else if (state === 'error') {
        void this.tryRemoteFallbackOnError()
          .then((recovered: boolean) => {
            if (recovered) {
              return
            }
            console.error(`[AvPlayerBridge] 播放器错误，当前URL: ${this.currentSong.url}`)
            this.currentSong.isPlay = false
            sessionManager.setAVPlayBackState()
          })
          .catch((e: Error) => {
            console.error('[AvPlayerBridge] 远程回退异常:', e)
            this.currentSong.isPlay = false
            sessionManager.setAVPlayBackState()
          })
      }
    })

    this.player.on('error', (error) => {
      void this.tryRemoteFallbackOnError()
        .then((recovered: boolean) => {
          if (recovered) {
            return
          }
          console.error(`[AvPlayerBridge] 播放错误: code=${error.code}, message=${error.message}, url=${this.currentSong.url}`)
          this.currentSong.isPlay = false
          sessionManager.setAVPlayBackState()
        })
        .catch((e: Error) => {
          console.error('[AvPlayerBridge] 远程回退异常:', e)
          this.currentSong.isPlay = false
          sessionManager.setAVPlayBackState()
        })
    })

    this.player.on('durationUpdate', (duration) => {
      this.currentSong.duration = duration
      const currentSongItem = this.currentSong.playList[this.currentSong.playIndex]
      if (currentSongItem) {
        sessionManager.setAVMetadata(currentSongItem)
      }
    })

    this.player.on('timeUpdate', (time) => {
      this.currentSong.time = time
      // 降低 AVSession 状态更新频率，避免 IPC 频繁调用导致性能卡顿
      const now = Date.now()
      if (!this.lastStateUpdateTime || now - this.lastStateUpdateTime > 1000) {
        sessionManager.setAVPlayBackState()
        this.lastStateUpdateTime = now
      }
      // 进度落盘做节流，避免高频写入引起 I/O 压力。
      if (!this.lastSnapshotAt || now - this.lastSnapshotAt > 3000) {
        void playbackSnapshotStore.save(this.currentSong)
        this.lastSnapshotAt = now
      }
    })
  }

  singPlay(song: SongItemType): void {
    console.info(`[AvPlayerBridge] singPlay 被调用，歌曲: ${song.name}`)
    if (!this.player) {
      console.error('[AvPlayerBridge] 播放器未初始化，无法播放歌曲')
      return
    }
    console.info('[AvPlayerBridge] 播放器已初始化，准备播放歌曲')
    const urlPreview = song.url.length > 100 ? `${song.url.substring(0, 100)}...` : song.url
    console.info(`[AvPlayerBridge] 播放歌曲: ${song.name}, URL: ${urlPreview}`)
    sessionManager.startBackgroundTask()
    sessionManager.setAVPlayBackState()

    const inList = this.currentSong.playList.some(item => item.id === song.id)
    const normalizedSongUrl = this.normalizeStreamUrl(song.url)
    const canPlayDirectly = this.currentSong.url === normalizedSongUrl && this.currentPlayerUrl.length > 0
    console.info(`[AvPlayerBridge] 歌曲是否在列表中: ${inList}`)
    if (inList) {
      if (canPlayDirectly) {
        console.info('[AvPlayerBridge] 播放同一首歌曲，直接播放')
        this.player?.play()
        this.currentSong.isPlay = true
        console.info(`[AvPlayerBridge] 播放状态已更新: ${this.currentSong.isPlay}`)
        void playbackSnapshotStore.save(this.currentSong)
      } else {
        console.info('[AvPlayerBridge] 切换到列表中的其他歌曲')
        this.currentSong.playIndex = this.currentSong.playList.findIndex(item => item.id === song.id)
        console.info(`[AvPlayerBridge] 新的播放索引: ${this.currentSong.playIndex}`)
        this.changeSong()
      }
    } else {
      console.info('[AvPlayerBridge] 歌曲不在列表中，添加到列表')
      this.currentSong.playList.unshift(song)
      this.currentSong.playIndex = 0
      console.info(`[AvPlayerBridge] 新的播放索引: ${this.currentSong.playIndex}`)
      this.changeSong()
    }
  }

  singPlayFromList(song: SongItemType, playList: SongItemType[]): void {
    if (!this.player) {
      console.error('[AvPlayerBridge] 播放器未初始化，无法播放歌曲')
      return
    }
    sessionManager.startBackgroundTask()
    sessionManager.setAVPlayBackState()
    const idx = playList.findIndex((item: SongItemType) => item.id === song.id)
    this.currentSong.playList = [...playList]
    this.currentSong.playIndex = idx >= 0 ? idx : 0
    void playbackSnapshotStore.save(this.currentSong)
    this.changeSong()
  }

  async changeSong(): Promise<void> {
    if (!this.player) {
      console.error('[AvPlayerBridge] 播放器未初始化，无法切换歌曲')
      return
    }
    if (this.currentSong.playList.length === 0) {
      console.error('[AvPlayerBridge] 播放列表为空，无法切换歌曲')
      this.currentSong.isPlay = false
      sessionManager.setAVPlayBackState()
      return
    }

    try {
      console.info('[AvPlayerBridge] 开始切换歌曲...')
      await this.player.reset()
      console.info('[AvPlayerBridge] 播放器重置完成')

      this.currentSong.duration = 0
      this.currentSong.time = 0

      const song = this.currentSong.playList[this.currentSong.playIndex]
      if (!song) {
        console.error('[AvPlayerBridge] 当前播放索引无效，无法切换歌曲')
        this.currentSong.isPlay = false
        sessionManager.setAVPlayBackState()
        return
      }

      this.currentSong.img = song.img
      this.currentSong.name = song.name
      this.currentSong.author = song.author
      this.currentSong.url = this.normalizeStreamUrl(song.url)
      this.currentSong.id = song.id
      this.currentSong.isFavorite = song.isFavorite
      this.currentSong.lyric = song.lyric
      this.currentSong.lyrics = song.lyrics
      this.currentSong.lyricLines = song.lyricLines || []
    
      if (!this.currentSong.lyricLines.length && song.lyric) {
        try {
          const lyricsParser = await import('./lyricsParser')
          this.currentSong.lyricLines = lyricsParser.parseLRC(song.lyric)
          if (!this.currentSong.lyricLines.length) {
            this.currentSong.lyrics = song.lyric
              .split(/\r?\n/)
              .map((line: string) => line.trim())
              .filter((line: string) => line.length > 0)
          }
        } catch (e) {
          console.error('[AvPlayerBridge] Failed to parse LRC: ', e)
        }
      }

      let playUrl = this.normalizeStreamUrl(song.url)
      this.canFallbackToRemote = false
      this.remoteFallbackTried = false
      this.remoteFallbackUrl = this.normalizeStreamUrl(song.url)
      try {
        const downloaded = await downloadManager.isDownloaded(song.id)
        if (downloaded) {
          const localPath = await downloadManager.getLocalPath(song.id)
          if (localPath && localPath.trim().length > 0) {
            playUrl = localPath
            this.canFallbackToRemote = true
            console.info(`[AvPlayerBridge] 使用离线文件播放: ${song.name}`)
          }
        }
      } catch (error) {
        console.error('[AvPlayerBridge] 离线路径检查失败，回退网络播放:', JSON.stringify(error))
      }

      const urlPreview = playUrl.length > 100 ? `${playUrl.substring(0, 100)}...` : playUrl
      console.info(`[AvPlayerBridge] 设置播放URL: ${urlPreview}, 歌曲: ${song.name}`)

      this.player.url = playUrl
      this.currentPlayerUrl = playUrl
      console.info('[AvPlayerBridge] URL已设置，等待播放器初始化...')
      void playbackSnapshotStore.save(this.currentSong)
    } catch (error) {
      console.error('[AvPlayerBridge] 切换歌曲失败:', error)
      this.currentSong.isPlay = false
      sessionManager.setAVPlayBackState()
    }
  }

  private async tryRemoteFallbackOnError(): Promise<boolean> {
    if (!this.player) {
      return false
    }
    if (!this.canFallbackToRemote || this.remoteFallbackTried || !this.remoteFallbackUrl) {
      return false
    }

    this.remoteFallbackTried = true
    try {
      console.info(`[AvPlayerBridge] 本地文件播放失败，回退远程流: ${this.remoteFallbackUrl}`)
      await this.player.reset()
      this.currentPlayerUrl = ''
      this.player.url = this.remoteFallbackUrl
      this.currentPlayerUrl = this.remoteFallbackUrl
      return true
    } catch (error) {
      console.error('[AvPlayerBridge] 远程回退失败:', error)
      return false
    }
  }

  seekPlay(value: number): void {
    console.info(`[AvPlayerBridge] seekPlay 被调用，跳转到: ${value}ms`)
    if (!this.player) {
      console.error('[AvPlayerBridge] 播放器未初始化，无法跳转进度')
      return
    }
    this.player.seek(value)
    console.info('[AvPlayerBridge] 跳转进度完成')
  }

  paused(): void {
    console.info('[AvPlayerBridge] paused 被调用')
    if (!this.player) {
      console.error('[AvPlayerBridge] 播放器未初始化，无法暂停')
      return
    }
    console.info('[AvPlayerBridge] 执行暂停操作')
    this.player.pause()
    this.currentSong.isPlay = false
    console.info(`[AvPlayerBridge] 暂停状态已更新: ${this.currentSong.isPlay}`)
    sessionManager.setAVPlayBackState()
    void playbackSnapshotStore.save(this.currentSong)
    void sessionManager.stopBackgroundTask()
  }

  prevPlay(): void {
    if (this.currentSong.playList.length === 0) {
      console.error('[AvPlayerBridge] 播放列表为空，无法切换到上一首')
      return
    }

    if (this.currentSong.playMode === 'random') {
      this.currentSong.playIndex = Math.floor(Math.random() * this.currentSong.playList.length)
    } else {
      this.currentSong.playIndex--
      if (this.currentSong.playIndex < 0) {
        this.currentSong.playIndex = this.currentSong.playList.length - 1
      }
    }

    this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
  }

  nextPlay(autoNextPlay?: boolean): void {
    if (this.currentSong.playList.length === 0) {
      console.error('[AvPlayerBridge] 播放列表为空，无法切换到下一首')
      return
    }

    if (this.currentSong.playMode === 'repeat' && autoNextPlay) {
      // 索引保持不变
    } else if (this.currentSong.playMode === 'random') {
      this.currentSong.playIndex = Math.floor(Math.random() * this.currentSong.playList.length)
    } else {
      this.currentSong.playIndex++
      if (this.currentSong.playIndex > this.currentSong.playList.length - 1) {
        this.currentSong.playIndex = 0
      }
    }

    this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
  }

  removeSong(index: number): void {
    if (index === this.currentSong.playIndex) {
      if (this.currentSong.playList.length > 1) {
        this.currentSong.playList.splice(index, 1)
        if (this.currentSong.playIndex >= this.currentSong.playList.length) {
          this.currentSong.playIndex = 0
        }
        const nextSong = this.currentSong.playList[this.currentSong.playIndex]
        if (nextSong) {
          this.singPlay(nextSong)
        } else {
          this.player?.reset()
          this.currentSong.reset()
        }
      } else {
        this.player?.reset()
        this.currentSong.reset()
      }
    } else {
      if (index < this.currentSong.playIndex) {
        this.currentSong.playIndex--
      }
      this.currentSong.playList.splice(index, 1)
    }
  }

  async release(): Promise<void> {
    this.currentSong.isPlay = false
    this.currentPlayerUrl = ''
    void playbackSnapshotStore.save(this.currentSong)
    void sessionManager.stopBackgroundTask()
    await this.player?.release()
  }
}

export const playerBridge: AvPlayerBridge = new AvPlayerBridge()