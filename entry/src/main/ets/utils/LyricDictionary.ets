/**
 * Portfolio-safe demo lyrics.
 *
 * Public releases must not include complete copyrighted lyrics. The map keeps
 * the original lookup shape so lyric parsing and playback-page synchronization
 * can still be demonstrated with short original placeholder LRC content.
 */
const demoLyricAmbient = '[00:00.00]Demo lyric line for portfolio preview\n[00:08.00]Replace with legally licensed lyrics for local testing\n[00:16.00]This sample keeps the dictionary shape without copyrighted text'
const demoLyricHeritage = '[00:00.00]山风入耳 声音醒来\n[00:08.00]鼓点轻落 河岸展开\n[00:16.00]此处仅为原创演示歌词'
const demoLyricInstrumental = '[00:00.00]Instrumental demo\n[00:08.00]No commercial lyric content included\n[00:16.00]Configure licensed assets before release'

export const lyricDictionaryBySongId: Record<string, string> = {
  'demo-ambient-001': demoLyricAmbient,
  'demo-ambient-002': demoLyricInstrumental,
  'demo-heritage-001': demoLyricHeritage,
  'demo-heritage-002': demoLyricHeritage,
  'demo-heritage-003': demoLyricHeritage,
  'demo-heritage-004': demoLyricHeritage
}

/**
 * Finds lyrics by song ID. Returns undefined when the developer has not
 * configured a legal lyric resource for that song.
 */
export function findLyricBySongId(songId: string): string | undefined {
  const lyric = lyricDictionaryBySongId[songId]
  if (!lyric || lyric.trim().length === 0) {
    return undefined
  }
  return lyric
}
