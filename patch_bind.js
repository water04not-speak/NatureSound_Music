const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');
txt = txt.replace(/\\\$\\\$this\.isShowPlaylist/g, 'this.isShowPlaylist');
txt = txt.replace(/showClose: true \}\)/g, 'showClose: true, onDisappear: () => { this.isShowPlaylist = false; } })');
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', txt, 'utf-8');
