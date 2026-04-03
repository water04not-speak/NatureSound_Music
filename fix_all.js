const fs = require('fs');

// 1. Remove Zhao Lusi song
let seed = fs.readFileSync('entry/src/main/ets/utils/MusicSeedData.ets', 'utf-8');
seed = seed.replace(/\{\s*id:\s*'0048'[\s\S]*?\},?/g, '');
// Add helper class and function to avoid array typing issues in ArkTS
if (!seed.includes('SongItem')) {
    seed += `\nexport class SongItem {\n  img: string;\n  name: string;\n  author: string;\n  url: string;\n  id: string;\n  lyric?: string;\n  constructor(img: string, name: string, author: string, url: string, id: string, lyric?: string) {\n    this.img = img;\n    this.name = name;\n    this.author = author;\n    this.url = url;\n    this.id = id;\n    this.lyric = lyric;\n  }\n}\n\nexport function getDefaultSongItems(): SongItem[] {\n  return defaultMusicSeeds.map(s => new SongItem(s.cover, s.title, s.singer, s.url, s.id, s.lyric));\n}\n`;
}
fs.writeFileSync('entry/src/main/ets/utils/MusicSeedData.ets', seed, 'utf-8');

// 2. Refactor the files again properly
function replaceLines(filePath, startRegex, endRegex, replacement) {
    if (!fs.existsSync(filePath)) return;
    const lines = fs.readFileSync(filePath, 'utf-8').split('\n');
    let s = -1;
    let e = -1;
    for(let i=0; i<lines.length; i++) {
        if (s === -1 && lines[i].match(startRegex)) {
            s = i;
        } else if (s !== -1 && endRegex !== null && lines[i].match(endRegex)) {
            e = i - 1;
            while(e>s && (lines[e].trim() === '' || lines[e].trim() === ']')) e--;
            break;
        } else if (s !== -1 && endRegex === null && lines[i].includes('// 获取当前歌单相应的')) {
            e = i - 1;
            while(e>s && (lines[e].trim() === '' || lines[e].trim() === '}')) e--;
            break;
        }
    }
    
    if (s !== -1 && e !== -1) {
        console.log(`Replacing in ${filePath} from line ${s} to ${e}`);
        const before = lines.slice(0, s);
        let result = before.join('\n') + '\n' + replacement + '\n' + lines.slice(e + 1).join('\n');
        
        if (!result.includes('getDefaultSongItems')) {
            const importStmt = `import { getDefaultSongItems } from '../utils/MusicSeedData'`;
            let li = result.lastIndexOf('import ');
            if (li !== -1) {
                let eli = result.indexOf('\n', li);
                result = result.substring(0, eli + 1) + importStmt + '\n' + result.substring(eli + 1);
            } else {
                result = importStmt + '\n' + result;
            }
        }
        
        fs.writeFileSync(filePath, result, 'utf-8');
        console.log('Success ' + filePath);
    }
}

// Ensure proper syntax for ArkTS V2
replaceLines('entry/src/main/ets/pages/Community.ets', 
    /(?:private\\s+)?(?:readonly\\s+)?songs:\\s*SongItemType\[\]\s*=\s*\[/, 
    /^\s*(?:@Local|@State|private|public|build|momentList)/,
    '  private readonly songs: SongItemType[] = getDefaultSongItems()'
);

replaceLines('entry/src/main/ets/pages/Find.ets', 
    /(?:private\\s+)?songs:\\s*SongItemType\[\]\s*=\s*\[/, 
    /^\s*(?:@Local|@State|private|public|build|aboutToAppear)/,
    '  private songs: SongItemType[] = getDefaultSongItems()'
);

replaceLines('entry/src/main/ets/pages/Play.ets', 
    /(?:private\\s+)?(?:readonly\\s+)?songs:\\s*SongItemType\[\]\s*=\s*\[/, 
    /^\s*(?:@Local|@State|private|public|build|aboutToAppear|currentSong)/,
    '  private readonly songs: SongItemType[] = getDefaultSongItems()'
);

replaceLines('entry/src/main/ets/pages/HeritageRegionDetail.ets', 
    /songs:\s*SongItemType\[\]\s*=\s*\[/, 
    /^\s*(?:@Local|@State|private|public|build|aboutToAppear|currentSong|songList)/,
    '  songs: SongItemType[] = getDefaultSongItems()'
);

// PlaylistDetail is different. It uses map string keys
// We just need to replace the entire `private playlistSongsMap...` property block
let pd = fs.readFileSync('entry/src/main/ets/pages/PlaylistDetail.ets', 'utf-8');
let pd_s = pd.indexOf('private playlistSongsMap:');
let pd_e = pd.indexOf('  // 获取当前歌单');
if (pd_s !== -1 && pd_e !== -1) {
    let pd_before = pd.substring(0, pd_s);
    let pd_after = pd.substring(pd_e);
    let repl = 'private playlistSongsMap: Record<string, SongItemType[]> = {\n    \'pl-1\': getDefaultSongItems(),\n    \'default\': getDefaultSongItems()\n  }\n\n';
    let new_pd = pd_before + repl + pd_after;
    if (!new_pd.includes('getDefaultSongItems')) {
        new_pd = `import { getDefaultSongItems } from '../utils/MusicSeedData'\n` + new_pd;
    }
    fs.writeFileSync('entry/src/main/ets/pages/PlaylistDetail.ets', new_pd, 'utf-8');
    console.log('Success PlaylistDetail.ets');
}

// Recommend, Mine, MusicFeast had other arrays or imports modified before `git reset`. Let me check if they need update.
// Usually they use `defaultMusicSeeds` directly from `MusicSeedData.ets`.
