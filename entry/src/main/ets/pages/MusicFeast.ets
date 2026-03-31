// 非遗之声专区 - 地域非遗文化展示

import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import { HeritageRegionParams } from './HeritageRegionDetail'
import { SongItemType } from '../models/music'
import { getScreenWidthVp, resolveByScreenWidth } from '../utils/ScreenUtils'
import common from '@ohos.app.ability.common'
import { RelationalStoreHelper, MusicRecord } from '../utils/RelationalStoreHelper'

// 地域卡片类型
interface HeritageRegionItem {
  id: string
  name: string
  cover: ResourceStr
  description: string
  songs?: SongItemType[]
}

// 跳转页面入口函数
@Builder
export function MusicFeastBuilder() {
  MusicFeast()
}

@ComponentV2
export struct MusicFeast {
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!

  // 地域音乐数据
  @Local private regionList: HeritageRegionItem[] = [
    {
      id: 'yangtze-delta',
      name: '长三角地区',
      cover: $r('app.media.csj01'),
      description: '江南丝竹、评弹小调、昆曲选段',
      songs: [
        {
          img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6cVHkHcjY27leNEticrH4QHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '迷雾',
          author: '吴子健REmi',
          url: 'http://music.163.com/song/media/outer/url?id=3329325495.mp3',
          id: '0015'
        }
      ]
    },
    {
      id: 'guangdong-hk-macao',
      name: '粤港澳地区',
      cover: $r('app.media.yga01'),
      description: '广府粤曲、粤语童谣、醒狮鼓点',
      songs: [
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.hnGq0kOiFyAgNrW3ufiq0wHaC4?w=240&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: '紫荆花盛开 ',
          author: '李荣浩,梁咏琪',
          url: 'http://music.163.com/song/media/outer/url?id=1959528822.mp3',
          id: '0010'
        }
      ]
    },
    {
      id: 'chengdu-chongqing',
      name: '成渝地区',
      cover: $r('app.media.cy01'),
      description: '川剧念白、川剧鼓点音效',
      songs: [
        {
          img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6cVHkHcjY27leNEticrH4QHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '迷雾',
          author: '吴子健REmi',
          url: 'http://music.163.com/song/media/outer/url?id=3329325495.mp3',
          id: '0015'
        }
      ]
    },
    {
      id: 'yangtze-mid',
      name: '长江中游地区',
      cover: $r('app.media.cjzy01'),
      description: '楚调湘音、黄梅戏选段',
      songs: [
        {
          img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6cVHkHcjY27leNEticrH4QHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '迷雾',
          author: '吴子健REmi',
          url: 'http://music.163.com/song/media/outer/url?id=3329325495.mp3',
          id: '0015'
        }
      ]
    },
    {
      id: 'ancient-style',
      name: '古风音乐',
      cover: $r('app.media.gf01'),
      description: '古典乐器、传统曲调、古风流行',
      songs: [
        {
          img: 'https://ts2.tc.mm.bing.net/th/id/OIP-C.S0lemtICbjqpaSpjD1X5fgHaHa?w=200&h=200&c=12&rs=1&p=0&o=6&dpr=1.5&pid=23.1',
          name: '吹梦到西洲',
          author: '恋恋故人难,黄诗扶,王敬轩（妖扬）',
          url: 'http://music.163.com/song/media/outer/url?id=1376873330.mp3',
          id: '0007'
        },
        {
          img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.pwQpy7yybxiaMVdf5JN1SwHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '青丝',
          author: '等什么君(邓寓君)',
          url: 'http://music.163.com/song/media/outer/url?id=1412672813.mp3',
          id: '0029'
        },
        {
          img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l84WVS0LEO3AkgPhgLd5BgHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '明月天涯 (翻自 五音JW)',
          author: '等什么君(邓寓君)',
          url: 'http://music.163.com/song/media/outer/url?id=1344878089.mp3',
          id: '0030'
        },
        {
          img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.803Wns_LS5LsyF9jPNCBJQHaHa?w=138&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '陌路逢君',
          author: '等什么君(邓寓君)',
          url: 'http://music.163.com/song/media/outer/url?id=1415078083.mp3',
          id: '0031'
        },
        {
          img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.r0bLQc8njyOVgXPYuNjSzwHaHa?w=146&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '囍（女生版）',
          author: '等什么君(邓寓君)',
          url: 'http://music.163.com/song/media/outer/url?id=1496822949.mp3',
          id: '0032'
        },
        {
          img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.oGXTK2UGnaPubp-8sK2z4gHaNK?w=114&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '故梦（Cover 橙翼）',
          author: '双笙（陈元汐）',
          url: 'http://music.163.com/song/media/outer/url?id=409654891.mp3',
          id: '0033'
        },
        {
          img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.SpdFHZJH6jCmCFpZdVONFgHaHa?w=161&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '我的一个道姑朋友',
          author: '双笙（陈元汐）',
          url: 'http://music.163.com/song/media/outer/url?id=1367452194.mp3',
          id: '0034'
        },
        {
          img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.8Ug45VtRuUQEKvQ_dFidwAHaEo?w=256&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '世末歌者（Cover 乐正绫）',
          author: '双笙（陈元汐）,封茗囧菌',
          url: 'http://music.163.com/song/media/outer/url?id=429460399.mp3',
          id: '0035'
        },
        {
          img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.Fa9_7omqnMvDG4ISsVHpgAAAAA?w=212&h=176&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '琴师',
          author: '徐泽（要不要买菜）',
          url: 'http://music.163.com/song/media/outer/url?id=1406119516.mp3',
          id: '0046'
        }
      ]
    },
    {
      id: 'modern-style',
      name: '现代音乐',
      cover: $r('app.media.xd01'),
      description: '流行歌曲、电子音乐、摇滚风格',
      songs: [
        {
          img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.du5HkZPRv8NeBiI8lyTe2gHaCu?w=343&h=128&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '消愁',
          author: '毛不易',
          url: 'http://music.163.com/song/media/outer/url?id=569200213.mp3',
          id: '0000'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C._LJNEo0ekqtNZL-BmOn3VAHaHa?w=199&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: 'Unit 731',
          author: 'Tim Moyo',
          url: 'http://music.163.com/song/media/outer/url?id=2731054516.mp3',
          id: '0001'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.6O62_eW-0x3-2s0cdubTigHaEN?w=253&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: 'YOUTH',
          author: 'Troye Sivan',
          url: 'http://music.163.com/song/media/outer/url?id=2731576429.mp3',
          id: '0002'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.S6-SPRMftLydAsbrGxMnKgHaHa?w=206&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: 'LOST BOY',
          author: 'Troye Sivan',
          url: 'http://music.163.com/song/media/outer/url?id=37988002.mp3',
          id: '0003'
        },
        {
          img: 'https://ts4.tc.mm.bing.net/th/id/OIP-C.l89zozjdw7Av41tZhMBLHQHaHZ?w=312&h=200&c=12&rs=1&o=6&dpr=1.5&pid=23.1',
          name: 'テロメアの産声',
          author: '4円',
          url: 'http://music.163.com/song/media/outer/url?id=26447699.mp3',
          id: '0004'
        },
        {
          img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.JsCp2kFMJQNUiJr1z6PztQAAAA?w=151&h=169&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: 'YELLOW',
          author: '4円',
          url: 'http://music.163.com/song/media/outer/url?id=1877061646.mp3',
          id: '0005'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.hsNjPtdOhkVKvQVC4ldOoQAAAA?w=179&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: 'My Heart Will Go On',
          author: '满舒克,MuSik I,廖伟珊',
          url: 'http://music.163.com/song/media/outer/url?id=26524701.mp3',
          id: '0006'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.b9__SJlShsleGBZklex6ewHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: '致你',
          author: 'yihuik苡慧',
          url: 'http://music.163.com/song/media/outer/url?id=1867217766.mp3',
          id: '0008'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.0reb7d1pRce8SAm-AiHyjAHaHa?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: '孤独患者',
          author: '杜宣达',
          url: 'http://music.163.com/song/media/outer/url?id=2642002866.mp3',
          id: '0009'
        },
        {
          img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.5vMonFOGX7ZQZxN4kAJq6wAAAA?w=190&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name: '精卫',
          author: '一颗狼星',
          url: 'http://music.163.com/song/media/outer/url?id=2019279516.mp3',
          id: '0011'
        },
        {
          img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.VuIUZtzmpXgromK5aXymdAHaHa?w=163&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '两 难',
          author: '加木',
          url: 'http://music.163.com/song/media/outer/url?id=2163210456.mp3',
          id: '0012'
        },
        {
          img: 'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/c8/c4/fa/c8c4fa47-55d8-b5ba-96e5-4b7de76b18e3/cover.jpg/1200x630wp-60.jpg',
          name: '戒断反应',
          author: '赵政豪',
          url: 'http://music.163.com/song/media/outer/url?id=2600442564.mp3',
          id: '0013'
        },
        {
          img: 'https://img3.kuwo.cn/star/albumcover/500/s4s61/83/1393076434.jpg',
          name: '给未来的自己',
          author: '余翊',
          url: 'http://music.163.com/song/media/outer/url?id=3327521028.mp3',
          id: '0014'
        },
        {
          img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6cVHkHcjY27leNEticrH4QHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '迷雾',
          author: '吴子健REmi',
          url: 'http://music.163.com/song/media/outer/url?id=3329325495.mp3',
          id: '0015'
        },
        {
          img:'https://tse4-mm.cn.bing.net/th/id/OIP-C.DbFschoMC4D56w-hISUNKwAAAA?w=188&h=188&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'霜月遥 - イノチの灯し方 (生命的点燃方式)',
          author:'霜月瑶',
          url:'http://music.163.com/song/media/outer/url?id=473403622.mp3',
          id:'0016'
        },
        {
          img:'https://tse3-mm.cn.bing.net/th/id/OIP-C.XCD3rC-U3JB5VemZf1NC1gHaEK?w=285&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'春日影',
          author:'CRYCHIC',
          url:'http://music.163.com/song/media/outer/url?id=2154464431.mp3',
          id:'0017'
        },
        {
          img:'https://ts1.tc.mm.bing.net/th/id/OIP-C.bkXzlU64xLuz4OR9A4mJdwAAAA?w=160&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name:'像雾',
          author:'徐秉龙',
          url:'http://music.163.com/song/media/outer/url?id=1941323235.mp3',
          id:'0018'
        },
        {
          img:'https://ts1.tc.mm.bing.net/th/id/OIP-C.GVsvj4J7mH4y5W-nJkY9XwAAAA?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name:'shall we talk.',
          author:'8bite',
          url:'http://music.163.com/song/media/outer/url?id=1986510161.mp3',
          id:'0020'
        },
        {
          img:'https://tse2-mm.cn.bing.net/th/id/OIP-C.61af9pSkqIrYBNohjSPBrAHaHa?w=170&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'越来越不懂（Cover 蔡健雅）',
          author:'青尢',
          url:'http://music.163.com/song/media/outer/url?id=498311468.mp3',
          id:'0021'
        },
        {
          img:'https://tse2-mm.cn.bing.net/th/id/OIP-C.vV33icWm5aacmPSnZHg4tgHaGO?w=184&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'勾指起誓',
          author:'青尢',
          url:'http://music.163.com/song/media/outer/url?id=1362503051.mp3',
          id:'0022'
        },
        {
          img:'https://tse2-mm.cn.bing.net/th/id/OIP-C.Wd5ltXER23yV7zpHskJnrwHaHa?w=178&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'夏天的风（Cover 温岚）',
          author:'青尢',
          url:'http://music.163.com/song/media/outer/url?id=519479311.mp3',
          id:'0023'
        },
        {
          img:"https://tse4-mm.cn.bing.net/th/id/OIP-C.1D9C1vapkptbrgC4gJfpzAHaEu?w=269&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
          name:'会不会（吉他版）',
          author:'刘大壮',
          url:'http://music.163.com/song/media/outer/url?id=1481164987.mp3',
          id:'0024'
        },
        {
          img:"https://tse2-mm.cn.bing.net/th/id/OIP-C.BjlCBcr1ivyWGIw-ltPSIQHaHa?w=176&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
          name:'我很好（吉他版）',
          author:'刘大壮',
          url:'http://music.163.com/song/media/outer/url?id=1491221473.mp3',
          id:'0025'
        },
        {
          img:"https://tse1-mm.cn.bing.net/th/id/OIP-C.-aRtG0KjxMEUlPQrqDnIuwHaHa?w=181&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
          name:'三号线（吉他版）',
          author:'刘大壮',
          url:'http://music.163.com/song/media/outer/url?id=1497799734.mp3',
          id:'0026'
        },
        {
          img:"https://tse4-mm.cn.bing.net/th/id/OIP-C.rU8WoMhtKnlk-VqRPbVYwgHaHa?w=173&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
          name:'同花顺',
          author:'en（王翊恩）',
          url:'http://music.163.com/song/media/outer/url?id=2709706245.mp3',
          id:'0027'
        },
        {
          img:"https://tse1-mm.cn.bing.net/th/id/OIP-C.7D2qL-1OoZ1foMTd05W3kwHaHa?w=177&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
          name:'想自由',
          author:'en（王翊恩）',
          url:'http://music.163.com/song/media/outer/url?id=2713633715.mp3',
          id:'0028'
        },
        {
          img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.cvib5ZJDR6YVN_AVEvuqlQHaI_?w=140&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '像我这样的人',
          author: '毛不易',
          url: 'http://music.163.com/song/media/outer/url?id=569213220.mp3',
          id: '0036'
        },
        {
          img:'https://tse4-mm.cn.bing.net/th/id/OIP-C.l89zozjdw7Av41tZhMBLHQHaHZ?w=162&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'文学少年の憂鬱',
          author:'4円',
          url:'http://music.163.com/song/media/outer/url?id=26447696.mp3',
          id:'0037'
        },
        {
          img:'https://tse4-mm.cn.bing.net/th/id/OIP-C.tdBGKfY0RY1jG9nGAGG4wwHaE6?w=253&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'北京东路的日子',
          author:'汪源',
          url:'http://music.163.com/song/media/outer/url?id=458245372.mp3',
          id:'0038'
        },
        {
          img:'https://tse3-mm.cn.bing.net/th/id/OIP-C.UnCdU7b4l1oRsWkoTYHDvAAAAA?w=156&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'仙',
          author:'江皓南',
          url:'http://music.163.com/song/media/outer/url?id=2705662118.mp3',
          id:'0039'
        },
        {
          img:'https://tse1-mm.cn.bing.net/th/id/OIP-C.oBBTKCjV31L4b55GaaVfGgHaHa?w=185&h=192&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'隐喻',
          author:'廖泽蓝,蘑菇鼠牙',
          url:'http://music.163.com/song/media/outer/url?id=3342356985.mp3',
          id:'0040'
        },
        {
          img:'https://tse1-mm.cn.bing.net/th/id/OIP-C.lMO1xR8TqlSl1Bu50Ll8uQAAAA?w=142&h=188&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'假说',
          author:'张齐山',
          url:'http://music.163.com/song/media/outer/url?id=2738482477.mp3',
          id:'0041'
        },
        {
          img:'https://tse3-mm.cn.bing.net/th/id/OIP-C.rtUjhJYVuztUUWDjvZD7LgHaHa?w=149&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'I Like Me Better',
          author:'Lauv',
          url:'http://music.163.com/song/media/outer/url?id=479223413.mp3',
          id:'0042'
        },
        {
          img:'https://tse4-mm.cn.bing.net/th/id/OIP-C.y_JPkbQMnC9apViwjVCcLgHaHa?w=184&h=184&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'形容',
          author:'沈以诚',
          url:'http://music.163.com/song/media/outer/url?id=1336856864.mp3',
          id:'0043'
        },
        {
          img:'https://tse4-mm.cn.bing.net/th/id/OIP-C.X-8rIiiyDZkw8PXJaLdeigAAAA?w=224&h=147&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'告白',
          author:'沈以诚',
          url:'http://music.163.com/song/media/outer/url?id=1336856449.mp3',
          id:'0044'
        },
        {
          img:'https://tse2-mm.cn.bing.net/th/id/OIP-C.PRwQ-ELVfPSBH6QfA_JL3wHaE7?w=280&h=187&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'日落大桥',
          author:'不是花火呀',
          url:'http://music.163.com/song/media/outer/url?id=1842743863.mp3',
          id:'0045'
        },
        {
          img:'https://tse3-mm.cn.bing.net/th/id/OIP-C.kUVSnw26NXrhSyFD0b-sWQHaGv?w=171&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'There\'s Nothing Holdin\'',
          author:'Me Back - Shawn Mendes',
          url:'http://music.163.com/song/media/outer/url?id=2656135242.mp3',
          id:'0047'
        }
      ]
    },
    {
      id: 'wuxia-style',
      name: '武侠音乐',
      cover: $r('app.media.wx01'),
      description: '江湖豪情、侠骨柔情、武侠剧配乐',
      songs: [
        {
          img:'https://ts1.tc.mm.bing.net/th/id/OIP-C.KTyTNlQIovW5FKx1e-N_vgHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
          name:'出山',
          author:'花粥,王胜娚',
          url:'http://music.163.com/song/media/outer/url?id=1313354324.mp3',
          id:'0019'
        },
        {
          img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l84WVS0LEO3AkgPhgLd5BgHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '明月天涯 (翻自 五音JW)',
          author: '等什么君(邓寓君)',
          url: 'http://music.163.com/song/media/outer/url?id=1344878089.mp3',
          id: '0030'
        }
      ]
    },
    {
      id: 'folk-style',
      name: '民谣音乐',
      cover: $r('app.media.my01'),
      description: '民间歌谣、地方特色、生活故事',
      songs: [
        {
          img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.du5HkZPRv8NeBiI8lyTe2gHaCu?w=343&h=128&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '消愁',
          author: '毛不易',
          url: 'http://music.163.com/song/media/outer/url?id=569200213.mp3',
          id: '0000'
        },
        {
          img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.cvib5ZJDR6YVN_AVEvuqlQHaI_?w=140&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name: '像我这样的人',
          author: '毛不易',
          url: 'http://music.163.com/song/media/outer/url?id=569213220.mp3',
          id: '0036'
        },
        {
          img:'https://tse4-mm.cn.bing.net/th/id/OIP-C.tdBGKfY0RY1jG9nGAGG4wwHaE6?w=253&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
          name:'北京东路的日子',
          author:'汪源',
          url:'http://music.163.com/song/media/outer/url?id=458245372.mp3',
          id:'0038'
        }
      ]
    }
  ]

  // 点击地域卡片，跳转到详情
  private handleRegionClick(region: HeritageRegionItem): void {
    const params = AppStorageV2.connect(HeritageRegionParams, 'heritageRegionParams', () => new HeritageRegionParams())!
    params.regionId = region.id
    params.regionName = region.name
    params.regionCover = region.cover
    params.regionDescription = region.description
    this.pathStack.pushPathByName('HeritageRegionDetail', null, false)
  }

  @Builder
  renderRegionCard(item: HeritageRegionItem) {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(item.cover as ResourceStr)
        .width('100%')
        .aspectRatio(1)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)

      // 底部渐变遮罩 + 简介
      Column() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text(item.description)
          .fontSize(12)
          .fontColor(Color.White)
          .opacity(0.9)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(12)
      .linearGradient({
        angle: 180,
        colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
      })
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .clip(true)
    .onClick(() => {
      this.handleRegionClick(item)
    })
  }

  // 响应式布局配置
  private getColumnsCount(): string {
    return resolveByScreenWidth(getScreenWidthVp(), '1fr 1fr', '1fr 1fr 1fr', '1fr 1fr 1fr 1fr')
  }

  @Local private musicList: MusicRecord[] = [];

  async loadMusicFromDatabase() {
    const ctx = getContext(this) as common.Context;
    const dbHelper = RelationalStoreHelper.getInstance();
    await dbHelper.initDatabase(ctx);
    this.musicList = await dbHelper.queryAllMusic();
  }

  async toggleFavorite(musicId: number, currentStatus: number) {
    const dbHelper = RelationalStoreHelper.getInstance();
    const newStatus = currentStatus === 1 ? 0 : 1;
    await dbHelper.updateFavoriteStatus(musicId, newStatus);
    await this.loadMusicFromDatabase();
  }

  build() {
    Column() {
      // 顶部标题区域
      Row() {
        Text('声宴')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .opacity(0.72)
        Text('  Music Feast ~')
          .fontSize(16)
          .opacity(0.5)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 4 })
      .justifyContent(FlexAlign.Start)

      // 音乐列表展示
      ForEach(this.musicList, (item: MusicRecord) => {
        Row() {
          Image(item.cover)
            .width(50)
            .height(50)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
          Column() {
            Text(item.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text(item.singer)
              .fontSize(14)
              .opacity(0.6)
          }
          .padding({ left: 8 })
          Button(item.isFavorite === 1 ? '取消收藏' : '收藏')
            .onClick(() => {
              this.toggleFavorite(item.id, item.isFavorite).catch((err: Error) => {
                console.error('toggleFavorite failed:', err);
              });
            });
        }
        .padding(8)
        .onClick(() => {
          // 播放音乐逻辑
        });
      }, (item: MusicRecord) => item.id.toString());
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.getBackgroundColor())
    .expandSafeArea()
    .onAppear(async () => {
      await this.loadMusicFromDatabase();
    });
  }
}
