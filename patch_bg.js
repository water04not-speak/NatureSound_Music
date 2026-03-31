const fs = require('fs');
let txt = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');

const bgReplacement = `          // Ðé»¯×¨¼­±³¾°
          Image(this.playState.img)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            .blur(60)

          // ±³¾°ÕÚÕÖ
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(this.themeState.getIsDark() ? 'rgba(0,0,0,0.6)' : 'rgba(255,255,255,0.7)')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])`;

txt = txt.replace(/\/\/\s*.[^\n]*?\n\s*Column\(\)\s*\n\s*\.width\('100%'\)\s*\n\s*\.height\('100%'\)\s*\n\s*\.backgroundColor\(this\.themeState\.getBackgroundColor\(\)\)\s*\n\s*\.expandSafeArea\(\[SafeAreaType\.SYSTEM\], \[SafeAreaEdge\.TOP, SafeAreaEdge\.BOTTOM\]\)/g, bgReplacement);

fs.writeFileSync('entry/src/main/ets/pages/Play.ets', txt, 'utf-8');
console.log('Background replaced');
