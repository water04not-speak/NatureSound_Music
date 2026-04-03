import { request } from '@kit.BasicServicesKit'
import { fileIo as fs } from '@kit.CoreFileKit'
import common from '@ohos.app.ability.common'
import dataPreferences from '@ohos.data.preferences'
import { promptAction } from '@kit.ArkUI'

/**
 * 全局后台下载管理实例 (DownloadManager)
 * 作用：实现离线音乐下载流（Phase 2: 本地/离线生态），持久化已下载的媒体缓存映射。
 */
export class DownloadManager {
  private static instance: DownloadManager
  private downloadingSet: Set<string> = new Set() 
  private prefs: dataPreferences.Preferences | null = null

  public static getInstance(): DownloadManager {
    if (!DownloadManager.instance) {
      DownloadManager.instance = new DownloadManager()
    }
    return DownloadManager.instance
  }

  async init(context: common.UIAbilityContext) {
    if (!this.prefs) {
      this.prefs = await dataPreferences.getPreferences(context, 'offlineMusicStore')
    }
  }

  /**
   * 判断歌曲是否已被下载到沙箱
   */
  async isDownloaded(songId: string): Promise<boolean> {
    if (!this.prefs) return false
    const path = await this.prefs.get(songId, '') as string
    if (path) {
      try {
        const exist = fs.accessSync(path)
        if (exist) return true
        else {
          this.prefs.deleteSync(songId)
          this.prefs.flush()
        }
      } catch (e) {
        return false
      }
    }
    return false
  }

  /**
   * 获取下载的文件路径映射
   */
  async getLocalPath(songId: string): Promise<string> {
    if (!this.prefs) return ''
    return await this.prefs.get(songId, '') as string
  }

  /**
   * 执行原生下载任务
   */
  async downloadSong(context: common.UIAbilityContext, songId: string, url: string, name: string): Promise<void> {
    if (this.downloadingSet.has(songId)) {
      promptAction.showToast({ message: '歌曲正在下载中...' })
      return
    }

    const downloaded = await this.isDownloaded(songId)
    if (downloaded) {
      promptAction.showToast({ message: '歌曲已下载，可进行离线播放' })
      return
    }

    if (!this.prefs) {
      await this.init(context)
    }

    this.downloadingSet.add(songId)
    promptAction.showToast({ message: `开始下载: ${name}` })

    const filesDir = context.filesDir
    const fileName = `song_${songId}.mp3`
    const filePath = filesDir + '/' + fileName

    try {
      request.downloadFile(context, {
        url: url,
        filePath: filePath
      }).then((downloadTask: request.DownloadTask) => {
        downloadTask.on('complete', async () => {
          console.info(`[DownloadManager] 下载完成: ${name}`)
          await this.prefs?.put(songId, filePath)
          await this.prefs?.flush()
          this.downloadingSet.delete(songId)
          promptAction.showToast({ message: `下载完成: ${name}` })
        })

        downloadTask.on('fail', (err: number) => {
          console.error(`[DownloadManager] 下载失败: ${name}, err: ${err}`)
          this.downloadingSet.delete(songId)
          promptAction.showToast({ message: `下载失败: ${name}` })
        })
      }).catch((err: Error) => {
        console.error(`[DownloadManager] 下载API捕获到错误:`, err)
        this.downloadingSet.delete(songId)
        promptAction.showToast({ message: `下载初始化异常: ${err.message}` })
      })
    } catch (err) {
      console.error(`[DownloadManager] 下载运行异常:`, err)
      this.downloadingSet.delete(songId)
    }
  }
}

export const downloadManager = DownloadManager.getInstance()
