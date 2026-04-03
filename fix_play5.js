const fs=require('fs');
let p=fs.readFileSync('entry/src/main/ets/pages/Play.ets','utf8');
let lines = p.split('\n');
// the error was around line 322 or 343 which are `.justifyContent(FlexAlign.Center)`
// we check those lines and see what component they belong to
for(let i=0; i<lines.length; i++) {
  if (lines[i].includes(".justifyContent(FlexAlign.Center)")) {
    // we just remove this on line 322 and 343 if they are indeed Stack attributes
    if (i === 321 || i === 342) {
      lines[i] = "";
    }
  }
}
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', lines.join('\n'), 'utf8');
