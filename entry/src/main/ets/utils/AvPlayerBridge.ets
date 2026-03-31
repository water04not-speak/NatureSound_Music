import { media } from '@kit.MediaKit'
import { GlobalMusic } from '../models/globalMusic'
import { SongItemType } from '../models/music'
import { sessionManager } from './AvSessionManager'
import { currentSong as sharedCurrentSong } from './PlaybackState'

class AvPlayerBridge {
  player: media.AVPlayer | null = null
  currentSong: GlobalMusic = sharedCurrentSong

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
      } else if (state === 'completed') {
        this.nextPlay(true)
      } else if (state === 'released') {
        this.currentSong.reset()
      } else if (state === 'error') {
        console.error(`[AvPlayerBridge] 播放器错误，当前URL: ${this.currentSong.url}`)
        this.currentSong.isPlay = false
        sessionManager.setAVPlayBackState()
      }
    })

    this.player.on('error', (error) => {
      console.error(`[AvPlayerBridge] 播放错误: code=${error.code}, message=${error.message}, url=${this.currentSong.url}`)
      this.currentSong.isPlay = false
      sessionManager.setAVPlayBackState()
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
      sessionManager.setAVPlayBackState()
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
    console.info(`[AvPlayerBridge] 歌曲是否在列表中: ${inList}`)
    if (inList) {
      if (this.currentSong.url === song.url) {
        console.info('[AvPlayerBridge] 播放同一首歌曲，直接播放')
        this.player?.play()
        this.currentSong.isPlay = true
        console.info(`[AvPlayerBridge] 播放状态已更新: ${this.currentSong.isPlay}`)
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
      this.currentSong.url = song.url

      const urlPreview = song.url.length > 100 ? `${song.url.substring(0, 100)}...` : song.url
      console.info(`[AvPlayerBridge] 设置播放URL: ${urlPreview}, 歌曲: ${song.name}`)

      this.player.url = song.url
      console.info('[AvPlayerBridge] URL已设置，等待播放器初始化...')
    } catch (error) {
      console.error('[AvPlayerBridge] 切换歌曲失败:', error)
      this.currentSong.isPlay = false
      sessionManager.setAVPlayBackState()
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
    await this.player?.release()
  }
}

export const playerBridge: AvPlayerBridge = new AvPlayerBridge()