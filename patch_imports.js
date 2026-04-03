const fs = require('fs');
const files = ['entry/src/main/ets/pages/HeritageRegionDetail.ets', 'entry/src/main/ets/pages/Play.ets', 'entry/src/main/ets/pages/PlaylistDetail.ets'];
files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  if (!content.includes('getDefaultSongItems } from')) {
    content = content.replace(/import { AppStorageV2 } from '@kit\.ArkUI'\r?\n/, "import { AppStorageV2 } from '@kit.ArkUI'\nimport { getDefaultSongItems } from '../utils/MusicSeedData'\n");
    fs.writeFileSync(file, content);
    console.log('Updated ' + file);
  }
});
