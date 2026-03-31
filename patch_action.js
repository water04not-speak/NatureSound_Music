const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');

const actionReplacement = `            // 操作
            Row() {
              Image($r("app.media.ic_like"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  console.info('点赞被点击')
                })

              Image($r("app.media.ic_comment_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(26)
                .onClick(() => {
                  console.info('评论被点击')
                })

              Image($r("app.media.ic_bells_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  console.info('铃声被点击')
                })

              Image($r("app.media.ic_download_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  console.info('下载被点击')
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ top: 12, bottom: 24 })`;

const parts = txt.split('\n');
const startIdx = parts.findIndex(l => l.includes('Row() {') && parts[parts.indexOf(l)+1] && parts[parts.indexOf(l)+1].includes('Badge({ value: '));
if(startIdx !== -1) {
  let endIdx = startIdx;
  while(!parts[endIdx].includes('.justifyContent(FlexAlign.SpaceAround)')) {
    endIdx++;
  }
  parts.splice(startIdx - 1, endIdx - startIdx + 2, actionReplacement);
  fs.writeFileSync('entry/src/main/ets/pages/Play.ets', parts.join('\n'), 'utf-8');
  console.log('Successfully replaced action buttons');
} else {
  console.log('Could not find start idx');
}
