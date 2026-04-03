const fs = require('fs');
let t = fs.readFileSync('entry/src/main/ets/utils/AvPlayerBridge.ets', 'utf8');

// replace assigning to currentSong with assigning MORE fields
t = t.replace(
  /this\.currentSong\.url = song\.url/,
  `this.currentSong.url = song.url
      this.currentSong.id = song.id
      this.currentSong.isFavorite = song.isFavorite
      this.currentSong.lyric = song.lyric
      this.currentSong.lyrics = song.lyrics
      this.currentSong.lyricLines = song.lyricLines`
);

// We should also parse lyrics dynamically if song.lyricLines is not provided but lyric string is
// Wait, AvPlayerBridge was supposed to call lyricsParser, but it was deleted?
// Let's add parseLRC logic!
if (!t.includes('parseLRC(')) {
  t = t.replace(
    `this.currentSong.lyricLines = song.lyricLines`,
    `this.currentSong.lyricLines = song.lyricLines || []
    
      if (!this.currentSong.lyricLines.length && song.lyric) {
        try {
          const { parseLRC } = await import('./lyricsParser')
          this.currentSong.lyricLines = parseLRC(song.lyric)
        } catch (e) {
          console.error('[AvPlayerBridge] Failed to parse LRC: ', e)
        }
      }`
  );
}

fs.writeFileSync('entry/src/main/ets/utils/AvPlayerBridge.ets', t, 'utf8');
