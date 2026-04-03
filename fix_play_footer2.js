const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');
const searchStr = '.layoutWeight(1)';
let startIndex = txt.indexOf(searchStr);
// Find the next `Row` after layoutWeight(1) to be safe
let rowStart = txt.indexOf('Row() {', startIndex);
if (rowStart !== -1) {
  let endIndex = txt.indexOf('.width(\'100%\')', rowStart);
  if (endIndex !== -1) {
    let before = txt.substring(0, rowStart);
    let after = txt.substring(endIndex);
    let insert = `Row() {
              Image(this.playState.isFavorite ? $r('app.media.ic_like') : $r('app.media.ic_favorite'))
                .fillColor(this.playState.isFavorite ? '#ff4040' : this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(async () => {
                  if (!this.playState) return;
                  const abilityCtx = getContext(this) as any;
                  try {
                    const result = await musicRepository.toggleFavorite(abilityCtx, this.playState.id);
                    if (result) {
                      this.playState.isFavorite = result.isFavorite;
                    }
                  } catch (e) {
                      console.error('[Play] Failed to toggle favorite:', JSON.stringify(e));
                  }
                })

              Image($r('app.media.ic_comment_o'))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(26)

              Image($r('app.media.ic_bells_o'))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)

              Image($r('app.media.ic_download_o'))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(async () => {
                  try {
                    const dm = DownloadManager.getInstance();
                    const ctx = getContext(this) as any;
                    await dm.downloadSong(ctx, this.playState.id, this.playState.url, this.playState.name);
                  } catch (e) {
                      console.error('[Play] Download error:', JSON.stringify(e));
                  }
                })
            }
            `;
    fs.writeFileSync('entry/src/main/ets/pages/Play.ets', before + insert + after, 'utf-8');
    console.log('patched');
  } else { console.log('endIndex not found'); }
} else { console.log('rowStart not found'); }