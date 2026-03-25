import { LyricLine } from '../models/music'

/**
 * 解析 LRC 歌词字符串，得到带时间戳的歌词行。
 * 支持 [mm:ss.xx] 或 [mm:ss] 格式。
 * @param lrcContent LRC 文件内容
 * @returns 按时间排序的歌词行数组
 */
export function parseLRC(lrcContent: string): LyricLine[] {
  const lines = lrcContent.split(/\r?\n/)
  const result: LyricLine[] = []
  const timeTag = /\[(\d{1,2}):(\d{2})(?:\.(\d{2,3}))?\]/g

  for (const line of lines) {
    const trimmed = line.trim()
    if (!trimmed) continue

    let match: RegExpExecArray | null
    timeTag.lastIndex = 0

    while ((match = timeTag.exec(trimmed)) !== null) {
      const minute = parseInt(match[1], 10)
      const second = parseInt(match[2], 10)
      const ms = match[3] ? parseInt(match[3].padEnd(3, '0').substring(0, 3), 10) : 0
      const time = minute * 60 * 1000 + second * 1000 + ms
      const text = trimmed.substring(timeTag.lastIndex).trim()
      result.push({ time, text: text || ' ' })
    }
  }

  result.sort((a, b) => a.time - b.time)
  return result
}

/**
 * 从 LRC 解析出纯文本歌词行（无时间戳），用于 AVSession 或简单展示。
 */
export function parseLRCToPlainLines(lrcContent: string): string[] {
  return parseLRC(lrcContent).map((line: LyricLine) => line.text).filter((t: string) => t.trim().length > 0)
}
