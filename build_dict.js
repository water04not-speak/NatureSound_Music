const fs = require('fs');

const files = fs.readdirSync('f:/HarmonyOS_DevEnv/NatureSound_Music/歌词');
let dict = {};

files.forEach(f => {
  if(f.endsWith('.txt')) {
    let content = fs.readFileSync('f:/HarmonyOS_DevEnv/NatureSound_Music/歌词/' + f, 'utf8');
    
    // Convert CRLF to LF, and optionally escape backticks if you inject it into JS/TS template strings
    // content = content.replace(/`/g, '\\`'); 
    
    // Parse name: "1 消愁  毛不易.txt" -> "消愁"
    // Usually starts with number(s), then space, then song name, then singer.
    // We will just do a simple regex mapping for title.
    const match = f.match(/^\d+\s+(.*?)\s*(?:-.*)?\.txt$/);
    let title = f.replace(/^\d+\s+/, '').replace(/\.txt$/, '').trim();
    if (title.indexOf(' ') !== -1) {
        title = title.split(/\s+/)[0]; // get the first part (hopefully the song title)
    }

    dict[title] = content;
  }
});

fs.writeFileSync('f:/HarmonyOS_DevEnv/NatureSound_Music/lyrics_dict.json', JSON.stringify(dict, null, 2));
console.log('Done!');
