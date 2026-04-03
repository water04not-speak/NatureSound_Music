const fs = require('fs');
let p = fs.readFileSync('entry/src/main/ets/models/globalMusic.ets', 'utf8');
p = p.replace('import { SongItemType } from "./music"', 'import { SongItemType, LyricLine } from "./music"');
p = p.replace('@Trace lyricLines?: any[]', '@Trace lyricLines?: LyricLine[]');
fs.writeFileSync('entry/src/main/ets/models/globalMusic.ets', p, 'utf8');

let a = fs.readFileSync('entry/src/main/ets/utils/AvPlayerBridge.ets', 'utf8');
a = a.replace("const { parseLRC } = await import('./lyricsParser')", "const lyricsParser = await import('./lyricsParser')");
a = a.replace("parseLRC(song.lyric)", "lyricsParser.parseLRC(song.lyric)");
fs.writeFileSync('entry/src/main/ets/utils/AvPlayerBridge.ets', a, 'utf8');