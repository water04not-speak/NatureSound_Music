const fs = require('fs');
const dict = require('./lyrics_dict.json');
const path = require('path');

function replaceLyricsInFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;

    // Pattern to match name: 'Song Title' or title: 'Song Title'
    // and then insert lyric: `...` before or after it, but let's just do it cleanly
    // A regex to match an object in an array like { ..., name: 'Title', ... } Without a lyric field
    // It's brittle with regex to parse TS objects, but let's try a safe replacement.

    for (let title in dict) {
        if (!title || title.length < 2) continue; // skip too short
        let lyricText = dict[title].replace(/`/g, '\\`'); // escape backticks for JS template literal
        
        // Let's replace: title: 'Title',
        // with: title: 'Title', lyric: `...`,
        
        // name: 'Title'
        // name: "Title"
        let reNameSingle = new RegExp(`name:\\s*'${title}'`, 'g');
        let reNameDouble = new RegExp(`name:\\s*"${title}"`, 'g');
        let reTitleSingle = new RegExp(`title:\\s*'${title}'`, 'g');
        let reTitleDouble = new RegExp(`title:\\s*"${title}"`, 'g');

        if (content.match(reNameSingle)) {
            content = content.replace(reNameSingle, `name: '${title}', lyric: \`${lyricText}\``);
            changed = true;
        }
        if (content.match(reNameDouble)) {
            content = content.replace(reNameDouble, `name: '${title}', lyric: \`${lyricText}\``);
            changed = true;
        }
        if (content.match(reTitleSingle)) {
            content = content.replace(reTitleSingle, `title: '${title}', lyric: \`${lyricText}\``);
            changed = true;
        }
        if (content.match(reTitleDouble)) {
            content = content.replace(reTitleDouble, `title: '${title}', lyric: \`${lyricText}\``);
            changed = true;
        }
    }

    // However, if we do multiple passes, we might duplicate lyric keys. Let's fix that.
    // Replace: lyric: `some text`, lyric: `some text` -> lyric: `some text`
    content = content.replace(/(lyric:\s*`[\s\S]*?`),\s*lyric:\s*`[\s\S]*?`/g, '$1');

    if (changed) {
        // Also ensure lyric: is allowed in the interface if missing?
        fs.writeFileSync(filePath, content);
        console.log('Updated lyrics in: ' + filePath);
    }
}

const targetFiles = [
    'entry/src/main/ets/utils/MusicSeedData.ets',
    'entry/src/main/ets/pages/Community.ets',
    'entry/src/main/ets/pages/HeritageRegionDetail.ets',
    'entry/src/main/ets/pages/MusicFeast.ets',
    'entry/src/main/ets/pages/PlaylistDetail.ets'
];

targetFiles.forEach(f => {
    let p = path.join(__dirname, f);
    if (fs.existsSync(p)) {
        replaceLyricsInFile(p);
    }
});
