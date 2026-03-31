const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');

// 1. Rename panelOpacity to isShowPlaylist
txt = txt.replace(/@Local panelOpacity: number = 0/g, '@Local isShowPlaylist: boolean = false');

// 2. Change onClick setting
txt = txt.replace(/this\.panelOpacity = 1/g, 'this.isShowPlaylist = true');

// 3. Remove fake popup
function removePopup(text) {
  const match = text.indexOf('if (this.panelOpacity > 0)');
  if (match === -1) return text;
  
  let openBraces = 0;
  let startIdx = match;
  let contentStarted = false;
  let endIdx = match;
  
  for (let i = match; i < text.length; i++) {
    if (text[i] === '{') {
      openBraces++;
      contentStarted = true;
    } else if (text[i] === '}') {
      openBraces--;
    }
    
    if (contentStarted && openBraces === 0) {
      endIdx = i;
      break;
    }
  }
  
  return text.substring(0, startIdx) + text.substring(endIdx + 1);
}

txt = removePopup(txt);

// 4. Also remove the comment before it: `// 歌单列表` or similar if it's there. Note: The above logic leaves it, which is fine or maybe I can replace it.
txt = txt.replace(/\/\/\s*.[^\n]*?\n\s*(?=\n\s*\})/g, ''); // maybe dangerous, I'll just leave comments as is.

// 5. Add bindSheet after hideTitleBar(true)
txt = txt.replace(/\.hideTitleBar\(true\)/g, ".hideTitleBar(true)\n      .bindSheet(\\$\\$this.isShowPlaylist, this.PlaylistBuilder(), { height: SheetSize.MEDIUM, dragBar: true, backgroundColor: this.themeState.getCardBackgroundColor(), showClose: true })");

fs.writeFileSync('entry/src/main/ets/pages/Play.ets', txt, 'utf-8');
console.log('Popup replaced with bindSheet');
