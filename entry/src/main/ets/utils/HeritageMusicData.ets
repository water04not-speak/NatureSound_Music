// 音乐类型定义
import { SongItemType } from '../models/music'
import { MusicSongSeed } from '../models/musicDb'

// 传统文化音乐种子接口（扩展区域ID）
interface HeritageSeed extends MusicSongSeed {
  regionId: string
}

/**
 * 标准化流媒体URL（将HTTP转换为HTTPS）
 */
function normalizeStreamUrl(url: string): string {
  if (url.startsWith('http://music.163.com/')) {
    return 'https://' + url.substring('http://'.length)
  }
  return url
}

const heritageSeedsByRegion: Record<string, HeritageSeed[]> = {
  'yangtze-delta': [
    { id: 'h000', regionId: 'yangtze-delta', title: '欢乐歌', singer: '民乐', url: 'https://music.163.com/song/media/outer/url?id=5259247.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.pVp5RhSikU2DDsTE0QxeSwHaE8?w=270&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h001', regionId: 'yangtze-delta', title: '三六', singer: '周炳生', url: 'https://music.163.com/song/media/outer/url?id=29802872.mp3', cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.VRtOLlArAVfpqwsN6PAU6QAAAA?w=158&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h002', regionId: 'yangtze-delta', title: '莺莺拜月', singer: '侯莉君', url: 'https://music.163.com/song/media/outer/url?id=247149.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.vybPOLQES4LBfADLsPdH6QHaHa?w=149&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h003', regionId: 'yangtze-delta', title: '秦淮景', singer: '吴亮莹', url: 'https://music.163.com/song/media/outer/url?id=1406232229.mp3', cover: 'https://puui.qpic.cn/vpic_cover/c3512n6ggxf/c3512n6ggxf_1683183566_hz.jpg/1280' },
    { id: 'h004', regionId: 'yangtze-delta', title: '白蛇·赏中秋', singer: '蒋月泉', url: 'https://music.163.com/song/media/outer/url?id=105734.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.M4zTP61wv_h1aZ5eU8W-mgAAAA?w=213&h=186&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h005', regionId: 'yangtze-delta', title: '牡丹亭·游园惊梦', singer: '梅兰芳,白云生,韩世昌', url: 'https://music.163.com/song/media/outer/url?id=1923225787.mp3', cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.nR6SX5GcEy9954eaW9g9BQHaKU?w=124&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h006', regionId: 'yangtze-delta', title: '长生殿·絮阁', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=5266378.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.mxEjCKVjDq-2F5ZDIs0EHQAAAA?w=208&h=222&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h022', regionId: 'yangtze-delta', title: '适合深度睡眠的雨声(白噪音 助眠)', singer: '雨声', url: 'http://music.163.com/song/media/outer/url?id=2094433513.mp3', cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.J9Y2IoahhucUr1lc6wVq7QHaE7?w=238&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h023', regionId: 'yangtze-delta', title: '雷雨声', singer: 'X303FFF', url: 'http://music.163.com/song/media/outer/url?id=485533647.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.5AgHhWNQgjeGrmg9GbuMGQAAAA?w=273&h=183&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' }
  ],
  'guangdong-hk-macao': [
    { id: 'h007', regionId: 'guangdong-hk-macao', title: '分飞燕', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=5282935.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.GzenW0inyAA1jmpMM9HTowAAAA?w=182&h=182&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h008', regionId: 'guangdong-hk-macao', title: '帝女花', singer: '郑少秋,佩佩', url: 'https://music.163.com/song/media/outer/url?id=195616.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.ax0QLz18kKy7BM6n7OxY3gHaKY?w=133&h=187&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h009', regionId: 'guangdong-hk-macao', title: '彩云追月', singer: '嫚孋', url: 'https://music.163.com/song/media/outer/url?id=279344.mp3', cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.UCrCEt8DH4kv8WgZQ-Uj3wAAAA?w=206&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2' },
    { id: 'h010', regionId: 'guangdong-hk-macao', title: '氹氹转', singer: '小紫荆儿童合唱团', url: 'https://music.163.com/song/media/outer/url?id=388688.mp3', cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.IfK8L7m1EaXUU69162ffsAAAAA?w=161&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h011', regionId: 'guangdong-hk-macao', title: '落雨大', singer: '广州少儿广播合唱团', url: 'https://music.163.com/song/media/outer/url?id=1983785753.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.T2tPE46c8NE0yFmUJHk9AgHaHa?w=155&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h012', regionId: 'guangdong-hk-macao', title: '醒狮鼓乐', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=25730867.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.rnDVRLME-Uzxl43yfreB3gHaEJ?w=294&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h024', regionId: 'guangdong-hk-macao', title: '岭南早茶市井声', singer: 'Sound Effects', url: 'http://music.163.com/song/media/outer/url?id=530886415.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.vB3wgeoD6hN2cx6l43hp4wAAAA?w=130&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h025', regionId: 'guangdong-hk-macao', title: '纯篝火声', singer: '莫雨澤', url: 'http://music.163.com/song/media/outer/url?id=2022902126.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.EncIloGq1PP2knde70SeqAHaEJ?w=287&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' }
  ],
  'chengdu-chongqing': [
    { id: 'h013', regionId: 'chengdu-chongqing', title: '别洞观景', singer: '筱舫', url: 'https://music.163.com/song/media/outer/url?id=1899930770.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.fhYo85gggaivvIBL75EyIQHaE8?w=301&h=201&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h014', regionId: 'chengdu-chongqing', title: '连升店', singer: '周金福,陈宝亮', url: 'https://music.163.com/song/media/outer/url?id=1923444673.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.dMZbQPzODnK_o0KMXz7G1gHaFI?w=283&h=196&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h015', regionId: 'chengdu-chongqing', title: '川剧·贵妃醉酒', singer: '阳友鹤', url: 'https://music.163.com/song/media/outer/url?id=5266402.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.cFNK2TUUWX9dmsCg-1qQugHaE8?w=300&h=200&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h016', regionId: 'chengdu-chongqing', title: '变脸川剧鼓点', singer: '雾都游子', url: 'https://music.163.com/song/media/outer/url?id=2056203042.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.ddVmao1EJWB1vsCOWMGO8gHaFT?w=233&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h026', regionId: 'chengdu-chongqing', title: '巴蜀市井', singer: 'Sound Ideas', url: 'http://music.163.com/song/media/outer/url?id=569006293.mp3', cover: 'https://pic.nximg.cn/file/20220331/11140357_162943576129_2.jpg' },
    { id: 'h027', regionId: 'chengdu-chongqing', title: '流水声', singer: '森林的声音', url: 'http://music.163.com/song/media/outer/url?id=1487383256.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.2sp9omQHQeKXCEH_fr9NEQHaEX?w=307&h=181&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h028', regionId: 'chengdu-chongqing', title: '森林声（纯音助眠向）', singer: 'Elodina葵', url: 'http://music.163.com/song/media/outer/url?id=1295541303.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.C_e0LBmrHuCYT1R8X9laHAHaE7?w=273&h=182&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' }
  ],
  'yangtze-mid': [
    { id: 'h017', regionId: 'yangtze-mid', title: '拜月记', singer: '李忆兰', url: 'https://music.163.com/song/media/outer/url?id=1899033788.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.xm7HX1Wmt95eZHxwFpdJLAHaFN?w=273&h=193&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h018', regionId: 'yangtze-mid', title: '刘海砍樵(湖南花鼓戏)', singer: '李谷一', url: 'https://music.163.com/song/media/outer/url?id=1914675120.mp3', cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.TrXzBOYmRZ-i8hcyA9gOlwHaFj?w=246&h=184&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h019', regionId: 'yangtze-mid', title: '女驸马', singer: '韩再芬', url: 'https://music.163.com/song/media/outer/url?id=1501412078.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.S4b74px7Ght-QIlA_6AT7AAAAA?w=179&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h020', regionId: 'yangtze-mid', title: '天仙配', singer: '韩再芬,刘国平', url: 'https://music.163.com/song/media/outer/url?id=1501408933.mp3', cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.iSiO7zc4Eg2eKq5BVsA7OAHaE-?w=246&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h021', regionId: 'yangtze-mid', title: '打猪草', singer: '吴琼,张辉', url: 'https://music.163.com/song/media/outer/url?id=2165171173.mp3', cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.jRG1xmb6fpXEaiyOQBGQfgHaEK?w=333&h=187&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h029', regionId: 'yangtze-mid', title: '夜虫鸣', singer: '付文林', url: 'http://music.163.com/song/media/outer/url?id=1374941152.mp3', cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.CyTdN95n6M9P6Kf17mYOiQHaE7?w=239&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' },
    { id: 'h030', regionId: 'yangtze-mid', title: '树梢风声 白噪音ASMR睡眠', singer: '白噪音ASMR睡眠', url: 'http://music.163.com/song/media/outer/url?id=2040548534.mp3', cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.bpHy8TKTDuJzS2tHQWCA4gHaE1?w=286&h=187&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3' }
  ]
}

const flatHeritageSeeds: HeritageSeed[] = []
Object.keys(heritageSeedsByRegion).forEach((regionId: string) => {
  const list = heritageSeedsByRegion[regionId]
  list.forEach((item: HeritageSeed) => flatHeritageSeeds.push(item))
})

// 扁平化的传统文化音乐种子列表
export const heritageSeedSongs: MusicSongSeed[] = []
for (const item of flatHeritageSeeds) {
  const seed: MusicSongSeed = {
    id: item.id,
    title: item.title,
    singer: item.singer,
    url: normalizeStreamUrl(item.url),
    cover: item.cover,
    lyric: item.lyric
  }
  heritageSeedSongs.push(seed)
}

/**
 * 根据区域ID获取传统文化歌曲列表
 * @param regionId 区域标识
 * @returns 歌曲列表
 */
export function getHeritageSongsByRegionId(regionId: string): SongItemType[] {
  const list = heritageSeedsByRegion[regionId] ?? []
  const out: SongItemType[] = []
  for (const item of list) {
    const song: SongItemType = {
      id: item.id,
      name: item.title,
      author: item.singer,
      url: normalizeStreamUrl(item.url),
      img: item.cover,
      title: item.title,
      singer: item.singer,
      cover: item.cover,
      lyric: item.lyric
    }
    out.push(song)
  }
  return out
}
