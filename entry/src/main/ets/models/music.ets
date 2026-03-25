/** 带时间戳的歌词行（用于 LRC 解析与进度高亮） */
export interface LyricLine {
  time: number  // 毫秒
  text: string
}

export interface SongItemType {
  img: string
  name: string
  author: string
  url: string
  id: string
  /** 纯文本歌词行（可选），用于界面展示与锁屏/通知栏 */
  lyrics?: string[]
  /** 带时间戳的歌词行（可选），用于与播放进度同步高亮 */
  lyricLines?: LyricLine[]
}