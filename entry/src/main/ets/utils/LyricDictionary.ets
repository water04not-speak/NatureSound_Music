/**
 * 公开版演示歌词。
 *
 * 公开仓库不能保留完整受版权保护的歌词。这里保留短句原创占位内容，
 * 让歌词解析、播放页同步和数据结构展示仍然可以正常演示。
 */
const demoLyricAmbient = '[00:00.00]作品集演示歌词\n[00:08.00]本地运行可替换为合法授权歌词\n[00:16.00]公开仓库仅保留安全占位内容'
const demoLyricHeritage = '[00:00.00]山风入耳 声音醒来\n[00:08.00]鼓点轻落 河岸展开\n[00:16.00]此处仅为原创演示歌词'
const demoLyricInstrumental = '[00:00.00]纯音乐演示\n[00:08.00]公开版不包含商业歌词\n[00:16.00]请在本地配置合法授权资源'

export const lyricDictionaryBySongId: Record<string, string> = {
  'demo-ambient-001': demoLyricAmbient,
  'demo-ambient-002': demoLyricInstrumental,
  'demo-heritage-001': demoLyricHeritage,
  'demo-heritage-002': demoLyricHeritage,
  'demo-heritage-003': demoLyricHeritage,
  'demo-heritage-004': demoLyricHeritage
}

/**
 * 按歌曲 ID 查找歌词；未配置合法歌词时返回空值。
 */
export function findLyricBySongId(songId: string): string | undefined {
  const lyric = lyricDictionaryBySongId[songId]
  if (!lyric || lyric.trim().length === 0) {
    return undefined
  }
  return lyric
}
