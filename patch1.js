const fs = require('fs');
const txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');
const newTxt = txt.replace(/  private scrollThreshold: number = 5.*?\n  private scrollController: Scroller = new Scroller\(\)/gs, '  private scrollThreshold: number = 5\n  private scrollController: Scroller = new Scroller()\n' + fs.readFileSync('playlist_builder.txt', 'utf-8'));
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', newTxt, 'utf-8');
