const fs = require('fs');
let t = fs.readFileSync('entry/src/main/ets/models/globalMusic.ets', 'utf8');
t = t.replace('url: string = ""', 'url: string = ""\n  @Trace id: string = ""\n  @Trace lyric?: string\n  @Trace isFavorite?: boolean\n  @Trace lyrics?: string[]\n  @Trace lyricLines?: any[]');
fs.writeFileSync('entry/src/main/ets/models/globalMusic.ets', t, 'utf8');