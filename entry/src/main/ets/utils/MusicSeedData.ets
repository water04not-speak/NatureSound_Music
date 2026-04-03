import { MusicSongSeed } from '../models/musicDb'
import { findLyricBySongId } from './LyricDictionary'
import { heritageSeedSongs } from './HeritageMusicData'

function normalizeSeedUrl(url: string): string {
  if (url.startsWith('http://music.163.com/')) {
    return 'https://' + url.substring('http://'.length)
  }
  return url
}

export const defaultMusicSeeds: MusicSongSeed[] = [
  {
    id: '0000',
    title: '消愁',
    singer: '毛不易',
    url: 'http://music.163.com/song/media/outer/url?id=569200213.mp3',
    cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.du5HkZPRv8NeBiI8lyTe2gHaCu?w=343&h=128&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0001',
    title: 'Unit 731',
    singer: 'Tim Moyo',
    url: 'http://music.163.com/song/media/outer/url?id=2731054516.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C._LJNEo0ekqtNZL-BmOn3VAHaHa?w=199&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0002',
    title: 'YOUTH',
    singer: 'Troye Sivan',
    url: 'http://music.163.com/song/media/outer/url?id=2731576429.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.6O62_eW-0x3-2s0cdubTigHaEN?w=253&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0003',
    title: 'LOST BOY',
    singer: 'Troye Sivan',
    url: 'https://music.163.com/song/media/outer/url?id=3358682441.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.S6-SPRMftLydAsbrGxMnKgHaHa?w=206&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0004',
    title: 'テロメアの産声',
    singer: '4円',
    url: 'http://music.163.com/song/media/outer/url?id=26447699.mp3',
    cover: 'https://ts4.tc.mm.bing.net/th/id/OIP-C.l89zozjdw7Av41tZhMBLHQHaHZ?w=312&h=200&c=12&rs=1&o=6&dpr=1.5&pid=23.1'
  },
  {
    id: '0005',
    title: 'YELLOW',
    singer: '4円',
    url: 'http://music.163.com/song/media/outer/url?id=1877061646.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.JsCp2kFMJQNUiJr1z6PztQAAAA?w=151&h=169&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0006',
    title: 'My Heart Will Go On',
    singer: '满舒克,MuSik I,廖伟珊',
    url: 'http://music.163.com/song/media/outer/url?id=26524701.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.hsNjPtdOhkVKvQVC4ldOoQAAAA?w=179&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0007',
    title: '吹梦到西洲',
    singer: '恋恋故人难,黄诗扶,王敬轩（妖扬）',
    url: 'http://music.163.com/song/media/outer/url?id=1376873330.mp3',
    cover: 'https://ts2.tc.mm.bing.net/th/id/OIP-C.S0lemtICbjqpaSpjD1X5fgHaHa?w=200&h=200&c=12&rs=1&p=0&o=6&dpr=1.5&pid=23.1'
  },
  {
    id: '0008',
    title: '致你',
    singer: 'yihuik苡慧',
    url: 'http://music.163.com/song/media/outer/url?id=1867217766.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.b9__SJlShsleGBZklex6ewHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0009',
    title: '孤独患者',
    singer: '杜宣达',
    url: 'http://music.163.com/song/media/outer/url?id=2642002866.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.0reb7d1pRce8SAm-AiHyjAHaHa?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0010',
    title: '紫荆花盛开',
    singer: '李荣浩,梁咏琪',
    url: 'http://music.163.com/song/media/outer/url?id=1959528822.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.hnGq0kOiFyAgNrW3ufiq0wHaC4?w=240&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0011',
    title: '精卫',
    singer: '一颗狼星',
    url: 'http://music.163.com/song/media/outer/url?id=2019279516.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.5vMonFOGX7ZQZxN4kAJq6wAAAA?w=190&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0012',
    title: '两 难',
    singer: '加木',
    url: 'http://music.163.com/song/media/outer/url?id=2163210456.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.VuIUZtzmpXgromK5aXymdAHaHa?w=163&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0013',
    title: '戒断反应',
    singer: '赵政豪',
    url: 'http://music.163.com/song/media/outer/url?id=2600442564.mp3',
    cover: 'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/c8/c4/fa/c8c4fa47-55d8-b5ba-96e5-4b7de76b18e3/cover.jpg/1200x630wp-60.jpg'
  },
  {
    id: '0014',
    title: '给未来的自己',
    singer: '余翊',
    url: 'http://music.163.com/song/media/outer/url?id=3327521028.mp3',
    cover: 'https://img3.kuwo.cn/star/albumcover/500/s4s61/83/1393076434.jpg'
  },
  {
    id: '0015',
    title: '迷雾',
    singer: 'TC',
    url: 'https://music.163.com/song/media/outer/url?id=2026544587.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6cVHkHcjY27leNEticrH4QHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0016',
    title: '霜月遥 - イノチの灯し方 (生命的点燃方式)',
    singer: '霜月瑶',
    url: 'http://music.163.com/song/media/outer/url?id=473403622.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.DbFschoMC4D56w-hISUNKwAAAA?w=188&h=188&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0017',
    title: '春日影',
    singer: 'CRYCHIC',
    url: 'http://music.163.com/song/media/outer/url?id=2154464431.mp3',
    cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.XCD3rC-U3JB5VemZf1NC1gHaEK?w=285&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0018',
    title: '像雾',
    singer: '徐秉龙',
    url: 'http://music.163.com/song/media/outer/url?id=1941323235.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.bkXzlU64xLuz4OR9A4mJdwAAAA?w=160&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0019',
    title: '出山',
    singer: '花粥,王胜娚',
    url: 'http://music.163.com/song/media/outer/url?id=1313354324.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.KTyTNlQIovW5FKx1e-N_vgHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0020',
    title: 'shall we talk.',
    singer: '8bite',
    url: 'http://music.163.com/song/media/outer/url?id=1986510161.mp3',
    cover: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.GVsvj4J7mH4y5W-nJkY9XwAAAA?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2'
  },
  {
    id: '0021',
    title: '越来越不懂（Cover 蔡健雅）',
    singer: '青尢',
    url: 'http://music.163.com/song/media/outer/url?id=498311468.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.61af9pSkqIrYBNohjSPBrAHaHa?w=170&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0022',
    title: '勾指起誓',
    singer: '青尢',
    url: 'http://music.163.com/song/media/outer/url?id=1362503051.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.vV33icWm5aacmPSnZHg4tgHaGO?w=184&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0023',
    title: '夏天的风（Cover 温岚）',
    singer: '青尢',
    url: 'http://music.163.com/song/media/outer/url?id=519479311.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.Wd5ltXER23yV7zpHskJnrwHaHa?w=178&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0024',
    title: '会不会（吉他版）',
    singer: '刘大壮',
    url: 'http://music.163.com/song/media/outer/url?id=1481164987.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.1D9C1vapkptbrgC4gJfpzAHaEu?w=269&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0025',
    title: '我很好（吉他版）',
    singer: '刘大壮',
    url: 'http://music.163.com/song/media/outer/url?id=1491221473.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.BjlCBcr1ivyWGIw-ltPSIQHaHa?w=176&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0026',
    title: '三号线（吉他版）',
    singer: '刘大壮',
    url: 'http://music.163.com/song/media/outer/url?id=1497799734.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.-aRtG0KjxMEUlPQrqDnIuwHaHa?w=181&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0027',
    title: '同花顺',
    singer: 'en（王翊恩）',
    url: 'http://music.163.com/song/media/outer/url?id=2709706245.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.rU8WoMhtKnlk-VqRPbVYwgHaHa?w=173&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0028',
    title: '想自由',
    singer: 'en（王翊恩）',
    url: 'http://music.163.com/song/media/outer/url?id=2713633715.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.7D2qL-1OoZ1foMTd05W3kwHaHa?w=177&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0029',
    title: '青丝',
    singer: '等什么君(邓寓君)',
    url: 'http://music.163.com/song/media/outer/url?id=1412672813.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.pwQpy7yybxiaMVdf5JN1SwHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0030',
    title: '明月天涯 (翻自 五音JW)',
    singer: '等什么君(邓寓君)',
    url: 'http://music.163.com/song/media/outer/url?id=1344878089.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l84WVS0LEO3AkgPhgLd5BgHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0031',
    title: '陌路逢君',
    singer: '等什么君(邓寓君)',
    url: 'http://music.163.com/song/media/outer/url?id=1415078083.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.803Wns_LS5LsyF9jPNCBJQHaHa?w=138&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0032',
    title: '囍（女生版）',
    singer: '等什么君(邓寓君)',
    url: 'http://music.163.com/song/media/outer/url?id=1496822949.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.r0bLQc8njyOVgXPYuNjSzwHaHa?w=146&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0033',
    title: '故梦（Cover 橙翼）',
    singer: '双笙（陈元汐）',
    url: 'http://music.163.com/song/media/outer/url?id=409654891.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.oGXTK2UGnaPubp-8sK2z4gHaNK?w=114&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0034',
    title: '我的一个道姑朋友',
    singer: '双笙（陈元汐）',
    url: 'http://music.163.com/song/media/outer/url?id=1367452194.mp3',
    cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.SpdFHZJH6jCmCFpZdVONFgHaHa?w=161&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0035',
    title: '世末歌者（Cover 乐正绫）',
    singer: '双笙（陈元汐）,封茗囧菌',
    url: 'http://music.163.com/song/media/outer/url?id=429460399.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.8Ug45VtRuUQEKvQ_dFidwAHaEo?w=256&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0036',
    title: '像我这样的人',
    singer: '毛不易',
    url: 'http://music.163.com/song/media/outer/url?id=569213220.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.cvib5ZJDR6YVN_AVEvuqlQHaI_?w=140&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0037',
    title: '文学少年の憂鬱',
    singer: '4円',
    url: 'http://music.163.com/song/media/outer/url?id=26447696.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l89zozjdw7Av41tZhMBLHQHaHZ?w=162&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0038',
    title: '北京东路的日子',
    singer: '汪源',
    url: 'http://music.163.com/song/media/outer/url?id=458245372.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.tdBGKfY0RY1jG9nGAGG4wwHaE6?w=253&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0039',
    title: '仙',
    singer: '江皓南',
    url: 'http://music.163.com/song/media/outer/url?id=2705662118.mp3',
    cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.UnCdU7b4l1oRsWkoTYHDvAAAAA?w=156&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0040',
    title: '隐喻',
    singer: '廖泽蓝,蘑菇鼠牙',
    url: 'http://music.163.com/song/media/outer/url?id=3342356985.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.oBBTKCjV31L4b55GaaVfGgHaHa?w=185&h=192&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0041',
    title: '假说',
    singer: '张齐山',
    url: 'http://music.163.com/song/media/outer/url?id=2738482477.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.lMO1xR8TqlSl1Bu50Ll8uQAAAA?w=142&h=188&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0042',
    title: 'I Like Me Better',
    singer: 'Lauv',
    url: 'http://music.163.com/song/media/outer/url?id=479223413.mp3',
    cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.rtUjhJYVuztUUWDjvZD7LgHaHa?w=149&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0043',
    title: '形容',
    singer: '沈以诚',
    url: 'http://music.163.com/song/media/outer/url?id=1336856864.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.y_JPkbQMnC9apViwjVCcLgHaHa?w=184&h=184&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0044',
    title: '告白',
    singer: '沈以诚',
    url: 'http://music.163.com/song/media/outer/url?id=1336856449.mp3',
    cover: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.X-8rIiiyDZkw8PXJaLdeigAAAA?w=224&h=147&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0045',
    title: '日落大桥',
    singer: '不是花火呀',
    url: 'http://music.163.com/song/media/outer/url?id=1842743863.mp3',
    cover: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.PRwQ-ELVfPSBH6QfA_JL3wHaE7?w=280&h=187&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0046',
    title: '琴师',
    singer: '徐泽（要不要买菜）',
    url: 'http://music.163.com/song/media/outer/url?id=1406119516.mp3',
    cover: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.Fa9_7omqnMvDG4ISsVHpgAAAAA?w=212&h=176&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  {
    id: '0047',
    title: 'There\'s Nothing Holdin\'',
    singer: 'Me Back - Shawn Mendes',
    url: 'http://music.163.com/song/media/outer/url?id=2656135242.mp3',
    cover: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.kUVSnw26NXrhSyFD0b-sWQHaGv?w=171&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3'
  },
  
]

for (const seed of heritageSeedSongs) {
  defaultMusicSeeds.push(seed)
}

/**
 * 【通俗解释】这个类就是“给页面直接用的歌曲卡片结构”。
 * 数据库里的字段名和页面展示字段名不完全一致，
 * 所以这里做一次统一，避免每个页面都重复转换。
 */
export class SongItem {
  img: string;
  name: string;
  author: string;
  url: string;
  id: string;
  lyric?: string;
  constructor(img: string, name: string, author: string, url: string, id: string, lyric?: string) {
    this.img = img;
    this.name = name;
    this.author = author;
    this.url = url;
    this.id = id;
    this.lyric = lyric;
  }
}

export function getDefaultSongItems(): SongItem[] {
  /**
   * 【通俗解释】统一把流地址规范到 https，并且歌词只走词典按 ID 取值。
   * 这样既能减少播放器被 http 拦截，也避免只有个别歌曲使用内嵌歌词导致数据不一致。
   */
  return defaultMusicSeeds.map((s: MusicSongSeed) => {
    const resolvedLyric = findLyricBySongId(s.id)
    return new SongItem(s.cover, s.title, s.singer, normalizeSeedUrl(s.url), s.id, resolvedLyric)
  })
}
