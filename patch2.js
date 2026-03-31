const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');

const actionReplacement =               // ²Ù×÷
              Row() {
                Image( + '$r("app.media.ic_like")' + )
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(26)
                  .onClick(() => {
                  })
                Image( + '$r("app.media.ic_comment_o")' + )
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(26)
                  .onClick(() => {
                  })
                Image( + '$r("app.media.ic_bells_o")' + )
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(26)
                  .onClick(() => {
                  })
                Image( + '$r("app.media.ic_download_o")' + )
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(26)
                  .onClick(() => {
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceAround)
              .padding({ top: 12, bottom: 12 });

let reActionAlt = /\s*\/\/\s*.[^\n]*?\n\s*Row\(\) \{\s*\n\s*Badge\(\{.*?\}\s*\n\s*\}\s*\n\s*\.width\('100%'\)\s*\n\s*\.justifyContent\(FlexAlign\.SpaceAround\)/s;
txt = txt.replace(reActionAlt, '\n' + actionReplacement);
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', txt, 'utf-8');
console.log('Done');
