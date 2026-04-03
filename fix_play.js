const fs = require('fs');
let play = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf8');

if (!play.includes("import { DownloadManager }")) {
  play = "import { DownloadManager } from '../utils/DownloadManager';\n" + play;
}
if (!play.includes("import { musicRepository }")) {
  play = "import { musicRepository } from '../utils/MusicRepository';\n" + play;
}
if (!play.includes("import common from")) {
  play = "import common from '@ohos.app.ability.common';\n" + play;
}

play = play.replace(
  /\.justifyContent\(FlexAlign\.Center\)\s*\n\s*\.width\('100%'\)\s*\n\s*\.borderRadius\(400\)/,
  ".width('100%')\n                .borderRadius(400)"
);
play = play.replace(".index($$this.swiperIndex)", ".onChange((i: number) => { this.swiperIndex = i })");
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', play, 'utf8');
