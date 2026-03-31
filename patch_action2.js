const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');

const actionReplacement = `            // 操作
            Row() {
              Image($r("app.media.ic_like"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  console.info('点赞按钮被点击')
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

txt = txt.replace(/\/\/\s*.[^\n]*?\n\s*Row\(\) \{\s*\n\s*Badge\(\{[\s\S]*?\.justifyContent\(FlexAlign\.SpaceAround\)/g, actionReplacement);
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', txt, 'utf-8');
console.log('Done using regex string replace');
