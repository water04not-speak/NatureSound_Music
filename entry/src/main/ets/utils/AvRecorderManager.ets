// 录音管理器
// 参考华为开发者文档：https://developer.huawei.com/consumer/cn/doc/architecture-guides/music_player-0000002296726005
import { media } from '@kit.MediaKit'
import common from '@ohos.app.ability.common'
import fs from '@ohos.file.fs'

// 录音状态枚举
export enum RecordState {
  IDLE = 'idle',           // 空闲
  RECORDING = 'recording',  // 录音中
  PAUSED = 'paused',       // 暂停
  STOPPED = 'stopped'      // 已停止
}

// 录音配置接口
export interface RecordConfig {
  audioCodec: string  // 音频编码格式（CodecMimeType，如 'audio/mp4a-latm'）
  audioSampleRate: number  // 采样率（如 44100）
  numberOfChannels: number  // 声道数（1=单声道, 2=立体声）
  format: string  // 容器格式（如 'mp4', 'm4a'）
}

// 录音信息接口
export interface RecordInfo {
  filePath: string  // 录音文件路径
  duration: number  // 录音时长（毫秒）
  fileSize: number  // 文件大小（字节）
  createdAt: number  // 创建时间戳
}

/**
 * 录音管理器类
 * 负责管理音频录制功能
 */
export class AvRecorderManager {
  private recorder: media.AVRecorder | null = null
  private context?: common.UIAbilityContext
  private currentState: RecordState = RecordState.IDLE
  private recordStartTime: number = 0
  private recordPauseTime: number = 0
  private totalPauseDuration: number = 0
  private currentFilePath: string = ''
  private onStateChangeCallback?: (state: RecordState) => void
  private onDurationUpdateCallback?: (duration: number) => void

  /**
   * 初始化录音管理器
   */
  async init(ctx: common.UIAbilityContext): Promise<void> {
    this.context = ctx
    try {
      this.recorder = await media.createAVRecorder()
      this.setupRecorderEvents()
    } catch (error) {
      console.error('Failed to create AVRecorder:', error)
    }
  }

  /**
   * 设置录音器事件监听
   */
  private setupRecorderEvents(): void {
    if (!this.recorder) {
      return
    }

    // 状态变化监听
    this.recorder.on('stateChange', (state: string) => {
      console.info('Recorder state changed:', state)
      switch (state) {
        case 'idle':
          this.currentState = RecordState.IDLE
          break
        case 'prepared':
          // 准备就绪
          break
        case 'recording':
          this.currentState = RecordState.RECORDING
          this.recordStartTime = Date.now() - this.totalPauseDuration
          break
        case 'paused':
          this.currentState = RecordState.PAUSED
          this.recordPauseTime = Date.now()
          break
        case 'stopped':
          this.currentState = RecordState.STOPPED
          break
        case 'released':
          this.currentState = RecordState.IDLE
          break
        case 'error':
          console.error('Recorder error occurred')
          this.currentState = RecordState.IDLE
          break
      }
      if (this.onStateChangeCallback) {
        this.onStateChangeCallback(this.currentState)
      }
    })

    // 错误监听
    this.recorder.on('error', (error) => {
      console.error('Recorder error:', error)
      this.currentState = RecordState.IDLE
      if (this.onStateChangeCallback) {
        this.onStateChangeCallback(this.currentState)
      }
    })
  }

  /**
   * 开始录音
   * @param config 录音配置
   * @returns 录音文件路径
   */
  async startRecord(config?: RecordConfig): Promise<string> {
    if (!this.recorder || !this.context) {
      throw new Error('Recorder not initialized')
    }

    if (this.currentState === RecordState.RECORDING) {
      throw new Error('Already recording')
    }

    try {
      // 生成录音文件路径
      const filesDir = this.context.filesDir
      const recordsDir = `${filesDir}/records`
      
      // 确保录音目录存在
      try {
        if (!fs.accessSync(recordsDir)) {
          fs.mkdirSync(recordsDir)
        }
      } catch (e) {
        fs.mkdirSync(recordsDir)
      }

      // 生成文件名
      const timestamp = Date.now()
      const fileName = `record_${timestamp}.m4a`
      this.currentFilePath = `${recordsDir}/${fileName}`

      // 配置录音参数
      const defaultConfig: RecordConfig = {
        audioCodec: 'audio/mp4a-latm',  // AAC 编码的 MIME 类型
        audioSampleRate: 44100,  // 44.1kHz 采样率
        numberOfChannels: 2,  // 立体声
        format: 'mp4'  // MPEG-4 容器格式
      }

      // 构建录音配置
      // 注意：根据 HarmonyOS API，profile 中的类型需要匹配
      const audioCodecValue: string = config?.audioCodec || defaultConfig.audioCodec
      const fileFormatValue: string = config?.format || defaultConfig.format
      
      const recordConfig: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
        profile: {
          audioBitrate: 128000,
          audioChannels: config?.numberOfChannels || defaultConfig.numberOfChannels,
          audioCodec: audioCodecValue as media.CodecMimeType,
          audioSampleRate: config?.audioSampleRate || defaultConfig.audioSampleRate,
          fileFormat: fileFormatValue as media.ContainerFormatType
        },
        url: this.currentFilePath
      }

      // 准备录音
      await this.recorder.prepare(recordConfig)
      
      // 开始录音
      await this.recorder.start()
      
      this.recordStartTime = Date.now()
      this.totalPauseDuration = 0
      this.currentState = RecordState.RECORDING

      // 启动定时器更新时长
      this.startDurationTimer()

      return this.currentFilePath
    } catch (error) {
      console.error('Failed to start recording:', error)
      // ArkTS 要求只能抛出 Error 对象
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(`Failed to start recording: ${String(error)}`)
      }
    }
  }

  /**
   * 暂停录音
   */
  async pauseRecord(): Promise<void> {
    if (!this.recorder) {
      return
    }

    if (this.currentState !== RecordState.RECORDING) {
      return
    }

    try {
      await this.recorder.pause()
      this.recordPauseTime = Date.now()
      this.currentState = RecordState.PAUSED
    } catch (error) {
      console.error('Failed to pause recording:', error)
    }
  }

  /**
   * 恢复录音
   */
  async resumeRecord(): Promise<void> {
    if (!this.recorder) {
      return
    }

    if (this.currentState !== RecordState.PAUSED) {
      return
    }

    try {
      await this.recorder.resume()
      const pauseDuration = Date.now() - this.recordPauseTime
      this.totalPauseDuration += pauseDuration
      this.currentState = RecordState.RECORDING
      this.startDurationTimer()
    } catch (error) {
      console.error('Failed to resume recording:', error)
    }
  }

  /**
   * 停止录音
   * @returns 录音信息
   */
  async stopRecord(): Promise<RecordInfo | null> {
    if (!this.recorder) {
      return null
    }

    if (this.currentState === RecordState.IDLE || this.currentState === RecordState.STOPPED) {
      return null
    }

    try {
      await this.recorder.stop()
      this.currentState = RecordState.STOPPED

      // 计算录音时长
      const duration = Date.now() - this.recordStartTime - this.totalPauseDuration

      // 获取文件信息
      let fileSize = 0
      try {
        if (fs.accessSync(this.currentFilePath)) {
          const stat = fs.statSync(this.currentFilePath)
          fileSize = stat.size
        }
      } catch (e) {
        console.warn('Failed to get file size:', e)
      }

      const recordInfo: RecordInfo = {
        filePath: this.currentFilePath,
        duration: duration,
        fileSize: fileSize,
        createdAt: Date.now()
      }

      // 重置状态
      this.reset()

      return recordInfo
    } catch (error) {
      console.error('Failed to stop recording:', error)
      this.reset()
      return null
    }
  }

  /**
   * 取消录音（删除文件）
   */
  async cancelRecord(): Promise<void> {
    if (!this.recorder) {
      return
    }

    try {
      if (this.currentState === RecordState.RECORDING || this.currentState === RecordState.PAUSED) {
        await this.recorder.stop()
      }
      
      // 删除录音文件
      if (this.currentFilePath && fs.accessSync(this.currentFilePath)) {
        fs.unlinkSync(this.currentFilePath)
      }

      this.reset()
    } catch (error) {
      console.error('Failed to cancel recording:', error)
      this.reset()
    }
  }

  /**
   * 获取当前录音时长
   */
  getCurrentDuration(): number {
    if (this.currentState === RecordState.IDLE || this.currentState === RecordState.STOPPED) {
      return 0
    }

    if (this.currentState === RecordState.PAUSED) {
      return this.recordPauseTime - this.recordStartTime - this.totalPauseDuration
    }

    return Date.now() - this.recordStartTime - this.totalPauseDuration
  }

  /**
   * 获取当前状态
   */
  getCurrentState(): RecordState {
    return this.currentState
  }

  /**
   * 设置状态变化回调
   */
  setOnStateChangeCallback(callback: (state: RecordState) => void): void {
    this.onStateChangeCallback = callback
  }

  /**
   * 设置时长更新回调
   */
  setOnDurationUpdateCallback(callback: (duration: number) => void): void {
    this.onDurationUpdateCallback = callback
  }

  /**
   * 启动时长更新定时器
   */
  private startDurationTimer(): void {
    // 使用 setInterval 更新时长
    const timer = setInterval(() => {
      if (this.currentState === RecordState.RECORDING && this.onDurationUpdateCallback) {
        const duration = this.getCurrentDuration()
        this.onDurationUpdateCallback(duration)
      } else {
        clearInterval(timer)
      }
    }, 100) // 每100ms更新一次
  }

  /**
   * 重置状态
   */
  private reset(): void {
    this.currentState = RecordState.IDLE
    this.recordStartTime = 0
    this.recordPauseTime = 0
    this.totalPauseDuration = 0
    this.currentFilePath = ''
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    try {
      if (this.recorder) {
        if (this.currentState === RecordState.RECORDING || this.currentState === RecordState.PAUSED) {
          await this.recorder.stop()
        }
        await this.recorder.release()
        this.recorder = null
      }
      this.reset()
    } catch (error) {
      console.error('Failed to release recorder:', error)
    }
  }
}

// 导出单例
export const recorderManager = new AvRecorderManager()

