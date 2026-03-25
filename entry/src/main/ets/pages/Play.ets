import { GlobalMusic } from "../models/globalMusic"
import { SongItemType } from "../models/music"
import { AppStorageV2 } from "@kit.ArkUI"
import { playManager } from "../utils/AvPlayerManager"
import { ThemeState } from "../models/theme"

// 跳转页面入口函数
@Builder
export function PlayBuilder() {
  Play()
}

@ComponentV2
struct Play {
  @Local panelOpacity: number = 0
  @Local swiperIndex: number = 0  // 0=播放页 1=歌词页，左滑进入歌词
  pathStack : NavPathStack = new NavPathStack();

  songs: SongItemType[] = [
    {
      img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.KKrjA3kLTJU_2OlW2MUoLQHaHa?w=190&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
      name: 'Black Veil Bride',
      author: 'Rosy赵露思',
      url: 'http://music.163.com/song/media/outer/url?id=3312557251.mp3',
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
      img: 'https://ts2.tc.mm.bing.net/th/id/OIP-C.S0lemtICbjqpaSpjD1X5fgHaHa?w=200&h=200&c=12&rs=1&p=0&o=6&dpr=1.5&pid=23.1',
      name: '吹梦到西洲',
      author: '恋恋故人难,黄诗扶,王敬轩（妖扬）',
      url: 'http://music.163.com/song/media/outer/url?id=1376873330.mp3',
      id: '0007'
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
      img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.hnGq0kOiFyAgNrW3ufiq0wHaC4?w=240&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
      name: '紫荆花盛开 ',
      author: '李荣浩,梁咏琪',
      url: 'http://music.163.com/song/media/outer/url?id=1959528822.mp3',
      id: '0010'
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
      url:'http://music.163.com/song/media/outer/url?id=1805088638.mp3',
      id:'0016'
    },
    {
      img:'https://tse3-mm.cn.bing.net/th/id/OIP-C.XCD3rC-U3JB5VemZf1NC1gHaEK?w=285&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
      name:'春日影',
      author:'CRYCHIC',
      url:'http://music.163.com/song/media/outer/url?id=2149887904.mp3',
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
      img:'https://ts1.tc.mm.bing.net/th/id/OIP-C.KTyTNlQIovW5FKx1e-N_vgHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
      name:'出山',
      author:'花粥,王胜娚',
      url:'http://music.163.com/song/media/outer/url?id=1313354324.mp3',
      id:'0019'
    },
    {
      img:'https://ts1.tc.mm.bing.net/th/id/OIP-C.GVsvj4J7mH4y5W-nJkY9XwAAAA?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2',
      name:'shall we talk.',
      author:'8bite',
      url:'http://music.163.com/song/media/outer/url?id=1986510161.mp3',
      id:'0020'
    },
    {
      img:'https://cn.bing.com/images/search?q=%e8%b6%8a%e6%9d%a5%e8%b6%8a%e4%b8%8d%e6%87%82+%e9%9d%92%e5%b0%a2+%e5%9b%be%e7%89%87&id=C522B4A9B62C23CBE7A8FD80164EFF3F23C193ED&FORM=IQFRBA',
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
      img:"https://tse2-mm.cn.bing.net/th/id/OIP-C.pwQpy7yybxiaMVdf5JN1SwHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'青丝',
      author:'等什么君(邓寓君)',
      url:'http://music.163.com/song/media/outer/url?id=1412672813.mp3',
      id:'0029'
    },
    {
      img:"https://tse4-mm.cn.bing.net/th/id/OIP-C.l84WVS0LEO3AkgPhgLd5BgHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'明月天涯 (翻自 五音JW)',
      author:'等什么君(邓寓君)',
      url:'http://music.163.com/song/media/outer/url?id=1344878089.mp3',
      id:'0030'
    },
    {
      img:"https://tse4-mm.cn.bing.net/th/id/OIP-C.803Wns_LS5LsyF9jPNCBJQHaHa?w=138&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'陌路逢君',
      author:'等什么君(邓寓君)',
      url:'http://music.163.com/song/media/outer/url?id=1415078083.mp3',
      id:'0031'
    },
    {
      img:"https://tse2-mm.cn.bing.net/th/id/OIP-C.r0bLQc8njyOVgXPYuNjSzwHaHa?w=146&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'囍（女生版）',
      author:'等什么君(邓寓君)',
      url:'http://music.163.com/song/media/outer/url?id=1496822949.mp3',
      id:'0032'
    },
    {
      img:"https://tse2-mm.cn.bing.net/th/id/OIP-C.oGXTK2UGnaPubp-8sK2z4gHaNK?w=114&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'故梦（Cover 橙翼）',
      author:'双笙（陈元汐）',
      url:'http://music.163.com/song/media/outer/url?id=409654891.mp3',
      id:'0033'
    },
    {
      img:"https://tse3-mm.cn.bing.net/th/id/OIP-C.SpdFHZJH6jCmCFpZdVONFgHaHa?w=161&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'我的一个道姑朋友',
      author:'双笙（陈元汐）',
      url:'http://music.163.com/song/media/outer/url?id=1367452194.mp3',
      id:'0034'
    },
    {
      img:"https://tse1-mm.cn.bing.net/th/id/OIP-C.8Ug45VtRuUQEKvQ_dFidwAHaEo?w=256&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3",
      name:'世末歌者（Cover 乐正绫）',
      author:'双笙（陈元汐）,封茗囧菌',
      url:'http://music.163.com/song/media/outer/url?id=429460399.mp3',
      id:'0035'
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
      img:'https://tse1-mm.cn.bing.net/th/id/OIP-C.Fa9_7omqnMvDG4ISsVHpgAAAAA?w=212&h=176&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
      name:'琴师',
      author:'徐泽（要不要买菜）',
      url:'http://music.163.com/song/media/outer/url?id=1406119516.mp3',
      id:'0046'
    },
    {
      img:'https://tse3-mm.cn.bing.net/th/id/OIP-C.kUVSnw26NXrhSyFD0b-sWQHaGv?w=171&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3',
      name:'There\'s Nothing Holdin\'',
      author:'Me Back - Shawn Mendes',
      url:'http://music.163.com/song/media/outer/url?id=2656135242.mp3',
      id:'0047'
    },
  ]
  // 当前播放的歌曲
  @Local
  playState:GlobalMusic=AppStorageV2.connect(GlobalMusic,'SONG_KEY',()=>new GlobalMusic())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  aboutToAppear() {
    console.info('Play组件即将出现，检查播放列表')
    // 确保播放列表不为空
    if (this.playState.playList.length === 0 && this.songs.length > 0) {
      console.info('播放列表为空，初始化播放列表')
      this.playState.playList = [...this.songs]
      this.playState.playIndex = 0
      const firstSong = this.playState.playList[0]
      this.playState.img = firstSong.img
      this.playState.name = firstSong.name
      this.playState.author = firstSong.author
      this.playState.url = firstSong.url
      console.info('播放列表初始化完成，歌曲数量:', this.playState.playList.length)
    } else {
      console.info('播放列表已存在，歌曲数量:', this.playState.playList.length)
    }
  }
  // playState:SongItemType = this.songs[0]


  @Builder
  deleteButton(index: number) {
    Button('删除')
      .backgroundColor(this.themeState.getPlayPageForegroundColor())
      .fontColor(this.themeState.getCardBackgroundColor())
      .width(80)
      .height('100%')
      .type(ButtonType.Normal)
      .onClick(()=>{
        // 按接收到的索引删除歌曲
        playManager.removeSong(index)
        //   回退到前一页
        if(this.playState.playList.length===0){
          this.pathStack.pop()
        }
      })
  }

  number2time(number: number): string {
    // 毫秒 → 秒 → 分+秒; 先判断是否大于1分钟
    if (number > 60 * 1000) {
      const s = Math.floor(number/1000%60)
      const m = Math.floor(number/1000/60)
      const second = s.toString().padStart(2, '0')
      const minute = m.toString().padStart(2, '0')
      return minute + ':' + second
    } else {
      const s = Math.floor(number/1000%60)
      const second = s.toString().padStart(2, '0')
      return '00:' + second
    }
  }

  // 响应式布局配置
  private getScreenWidth(): number {
    return 360 // 默认值，避免使用可能不存在的API
  }

  private getScreenHeight(): number {
    return 640 // 默认值，避免使用可能不存在的API
  }

  private getRecordSize(): number {
    let screenWidth = this.getScreenWidth()
    if (screenWidth >= 1200) {
      return 500 // 2in1或大屏幕
    } else if (screenWidth >= 800) {
      return 400 // 平板
    } else {
      return 300 // 手机
    }
  }

  private getStylusSize(): number {
    let screenWidth = this.getScreenWidth()
    if (screenWidth >= 1200) {
      return 300 // 2in1或大屏幕
    } else if (screenWidth >= 800) {
      return 250 // 平板
    } else {
      return 200 // 手机
    }
  }

  private getTopMargin(): number {
    let screenHeight = this.getScreenHeight()
    if (screenHeight >= 1000) {
      return 120 // 大屏幕
    } else if (screenHeight >= 800) {
      return 80 // 平板
    } else {
      return 50 // 手机
    }
  }

  private getPanelHeight(): string {
    let screenHeight = this.getScreenHeight()
    if (screenHeight >= 1000) {
      return '70%' // 大屏幕
    } else if (screenHeight >= 800) {
      return '65%' // 平板
    } else {
      return '60%' // 手机
    }
  }

  // 滚动相关属性
  @Local scrollPosition: number = 0
  @Local showScrollTopButton: boolean = false
  @Local showScrollBottomButton: boolean = false
  private scrollThreshold: number = 5 // 当歌曲数量超过此值时启用滚动
  private scrollController: Scroller = new Scroller()

  build() {
    NavDestination() {
      Stack() {
        // 主题背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeState.getBackgroundColor())
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 内容
        Column() {
          //   播放界面
          Column() {
            // 图片
            Stack({ alignContent: Alignment.Top }) {
              Row() {
                Row() {
                  Image(this.playState.img)
                    .width('70%')
                    .borderRadius(400)
                }
                .backgroundImage($r('app.media.ic_cd'))
                .backgroundImageSize(ImageSize.Cover)
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .borderRadius(400)
                .clip(true)
                .aspectRatio(1)
              }
              .margin({ top: this.getTopMargin() })
              .width(this.getRecordSize())
              .aspectRatio(1)
              .justifyContent(FlexAlign.Center)
              .padding(24)
              // 唱针
              Image($r('app.media.ic_stylus'))
                .width(this.getStylusSize())
                .aspectRatio(1)
                .rotate({ angle: -55, centerX: this.getStylusSize() / 2, centerY: 30 })
                .animation({ duration: 500 })
            }
            // 歌曲信息（使用主题前景色保证对比度）
            Stack() {
              Column({ space: 8 }) {
                Text(this.playState.name)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeState.getPlayPageForegroundColor())
                Text(this.playState.author)
                  .fontSize(18)
                  .fontColor(this.themeState.getSecondaryTextColor())
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
            }
            .layoutWeight(1)
            // 操作
            Row() {
              Badge({ value: '99+', style: { badgeSize: 12, badgeColor: '#45CCCCCC' } }) {
                Image($r("app.media.ic_like"))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(24)
                  .onClick(() => {
                    console.info('点赞按钮被点击')
                  })
              }

              Badge({ value: '10W', style: { badgeSize: 12, badgeColor: '#45cccccc' } }) {
                Image($r("app.media.ic_comment_o"))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(18)
                  .onClick(() => {
                    console.info('评论按钮被点击')
                  })
              }

              Badge({ value: 'hot', style: { badgeSize: 12, badgeColor: '#a8ff3131' } }) {
                Image($r("app.media.ic_bells_o"))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(24)
                  .onClick(() => {
                    console.info('铃声按钮被点击')
                  })
              }

              Badge({ value: 'vip', style: { badgeSize: 12, badgeColor: '#b7efd371' } }) {
                Image($r("app.media.ic_download_o"))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(24)
                  .onClick(() => {
                    console.info('下载按钮被点击')
                  })
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            // 播放
            Column() {
              // 进度条
              Row({ space: 4 }) {
                Text(this.number2time(this.playState.time))
                  .fontSize(12)
                  .fontColor(this.themeState.getPlayPageForegroundColor())
                Slider({
                  value: this.playState.time,
                  min: 0,
                  max: this.playState.duration > 0 ? this.playState.duration : 10000
                })
                  .layoutWeight(1)
                  .blockColor(this.themeState.getPlayPageForegroundColor())
                  .selectedColor(this.themeState.getPlayPageForegroundColor())
                  .trackColor(this.themeState.getIsDark() ? '#66FFFFFF' : '#66000000')
                  .trackThickness(3)
                  .onChange((value)=>{
                    console.info('进度条被拖动，值为:', value)
                    playManager.seekPlay(value)
                  })
                Text(this.number2time(this.playState.duration))
                  .fontSize(12)
                  .fontColor(this.themeState.getPlayPageForegroundColor())
              }
              .width('100%')
              .padding(24)
              // 切换
              Row() {
                if(this.playState.playMode==='auto'){
                  Image($r('app.media.ic_auto'))
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                    .width(30)
                    .onClick(()=>{
                      console.info('播放模式切换为随机')
                      this.playState.playMode='random'
                    })
                }else if(this.playState.playMode==='random'){
                  Image($r('app.media.ic_random'))
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                    .width(30)
                    .onClick(()=>{
                      console.info('播放模式切换为重复')
                      this.playState.playMode='repeat'
                    })
                }else if(this.playState.playMode==='repeat'){
                  Image($r('app.media.ic_repeat'))
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                    .width(30)
                    .onClick(()=>{
                      console.info('播放模式切换为顺序')
                      this.playState.playMode='auto'
                    })
                }

                Image($r("app.media.ic_prev"))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(()=>{
                    console.info('上一首按钮被点击')
                    playManager.prevPlay()
                  })

                // 播放按钮
                Image(this.playState.isPlay?$r('app.media.ic_paused'):$r('app.media.ic_play'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(50)
                  .onClick(()=>{
                    console.info('播放按钮被点击，当前播放状态:', this.playState.isPlay)
                    if (this.playState.isPlay) {
                      console.info('调用playManager.paused()')
                      playManager.paused()
                    } else {
                      console.info('调用playManager.singPlay()')
                      if (this.playState.playList.length > 0 && this.playState.playIndex >= 0 && this.playState.playIndex < this.playState.playList.length) {
                        console.info('播放列表有歌曲，播放索引:', this.playState.playIndex)
                        playManager.singPlay(this.playState.playList[this.playState.playIndex])
                      } else {
                        // 播放列表为空或索引无效，初始化播放列表
                        console.info('播放列表为空或索引无效，初始化播放列表')
                        if (this.songs.length > 0) {
                          console.info('初始化播放列表，歌曲数量:', this.songs.length)
                          this.playState.playList = [...this.songs]
                          this.playState.playIndex = 0
                          const firstSong = this.playState.playList[0]
                          this.playState.img = firstSong.img
                          this.playState.name = firstSong.name
                          this.playState.author = firstSong.author
                          this.playState.url = firstSong.url
                          console.info('播放第一首歌曲:', firstSong.name)
                          playManager.singPlay(firstSong)
                        } else {
                          console.info('歌曲列表为空，无法播放')
                        }
                      }
                    }
                  })
                // 下一首
                Image($r('app.media.ic_next'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(()=>{
                    console.info('下一首按钮被点击')
                    playManager.nextPlay()
                  })
                // 播放列表
                Image($r('app.media.ic_song_list'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(() => {
                    console.info('播放列表按钮被点击，显示播放列表')
                    this.panelOpacity = 1
                  })
              }
              .width('100%')
              .padding({
                bottom: 24
              })
              .justifyContent(FlexAlign.SpaceAround)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
        }

        // 歌单列表
        if (this.panelOpacity > 0) {
          Stack() {
            // 背景遮罩，点击关闭面板
            Column() {

            }
            .width('100%')
            .height('100%')
            .onClick(() => {
              console.info('背景遮罩被点击，关闭面板')
              this.panelOpacity = 0
            })

            // 播放列表面板
            Column() {
              Row() {
                Row() {
                  Image($r("app.media.ic_play"))
                    .width(20)
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                }
                .width(50)
                .aspectRatio(1)
                .justifyContent(FlexAlign.Center)

                Row({ space: 8 }) {
                  // 反引号——>模板字符串——>支持${变量}
                  Text(`播放列表 (${this.playState.playList.length})`)
                    .fontColor(this.themeState.getPlayPageForegroundColor())
                    .fontSize(14)
                }
                .layoutWeight(1)

                Image($r('app.media.ic_close'))
                  .fillColor(this.themeState.getSecondaryTextColor())
                  .width(24)
                  .height(24)
                  .margin({ right: 16 })
                  .onClick(() => {
                    console.info('关闭按钮被点击')
                    this.panelOpacity = 0
                  })
              }
              .width('100%')
              .backgroundColor(this.themeState.getCardBackgroundColor())
              .padding(8)
              .border({
                width: { bottom: 1 },
                color: this.themeState.getDividerColor()
              })
              .borderRadius({
                topLeft: 4,
                topRight: 4
              })

              // 播放列表
              Column() {
                // 滚动容器
                if (this.playState.playList.length > this.scrollThreshold) {
                  Scroll(this.scrollController) {
                    List() {
                      ForEach(this.playState.playList, (item: SongItemType, index: number) => {
                        ListItem() {
                          Row() {
                            Row() {
                              Text((index + 1).toString())
                                .fontColor(this.themeState.getSecondaryTextColor())
                            }
                            .width(50)
                            .aspectRatio(1)
                            .justifyContent(FlexAlign.Center)

                            // 列表
                            Row({ space: 10 }) {
                              Column() {
                                Text(item.name)
                                  .fontSize(14)
                                  .fontColor(this.themeState.getPrimaryTextColor())
                                Text(item.author)
                                  .fontSize(12)
                                  .fontColor(this.themeState.getSecondaryTextColor())
                              }
                              .layoutWeight(1)
                              .alignItems(HorizontalAlign.Start)
                              .justifyContent(FlexAlign.Center)
                            }
                            .layoutWeight(1)

                            Image($r('app.media.ic_more'))
                              .width(24)
                              .height(24)
                              .margin({ right: 16 })
                              .fillColor(this.themeState.getIconColor())
                          }
                          .alignItems(VerticalAlign.Center)
                          .onClick(()=>{
                            console.info('列表项被点击，播放歌曲:', item.name)
                            playManager.singPlay(item)
                          })
                        }
                        // 侧滑
                        .swipeAction({
                          end: this.deleteButton(index)
                        })
                        .border({
                          width: { bottom: 1 },
                          color: this.themeState.getDividerColor()
                        })
                      })
                    }
                    .width('100%')
                    .divider({ strokeWidth: 0.5, color: this.themeState.getDividerColor() })
                  }
                  .layoutWeight(1)
                  .scrollBar(BarState.Auto)
                  .scrollBarColor(this.themeState.getPlayPageForegroundColor())
                  .scrollBarWidth(4)
                  .onScroll((_x: number, y: number) => {
                    this.scrollPosition = y
                    this.showScrollTopButton = y > 100
                    this.showScrollBottomButton = y < (this.playState.playList.length * 60 - this.getScreenHeight() * 0.6)
                  })
                } else {
                  // 不需要滚动时的普通列表
                  List() {
                    ForEach(this.playState.playList, (item: SongItemType, index: number) => {
                      ListItem() {
                        Row() {
                          Row() {
                            Text((index + 1).toString())
                              .fontColor(this.themeState.getSecondaryTextColor())
                          }
                          .width(50)
                          .aspectRatio(1)
                          .justifyContent(FlexAlign.Center)

                          // 列表
                          Row({ space: 10 }) {
                            Column() {
                              Text(item.name)
                                .fontSize(14)
                                .fontColor(this.themeState.getPrimaryTextColor())
                              Text(item.author)
                                .fontSize(12)
                                .fontColor(this.themeState.getSecondaryTextColor())
                            }
                            .layoutWeight(1)
                            .alignItems(HorizontalAlign.Start)
                            .justifyContent(FlexAlign.Center)
                          }
                          .layoutWeight(1)

                          Image($r('app.media.ic_more'))
                            .width(24)
                            .height(24)
                            .margin({ right: 16 })
                            .fillColor(this.themeState.getIconColor())
                        }
                        .alignItems(VerticalAlign.Center)
                        .onClick(()=>{
                          console.info('列表项被点击，播放歌曲:', item.name)
                          playManager.singPlay(item)
                        })
                      }
                      // 侧滑
                      .swipeAction({
                        end: this.deleteButton(index)
                      })
                      .border({
                        width: { bottom: 1 },
                        color: this.themeState.getDividerColor()
                      })
                    })
                  }
                  .layoutWeight(1)
                }

                // 滚动控制按钮
                if (this.playState.playList.length > this.scrollThreshold) {
                  Row() {
                    if (this.showScrollTopButton) {
                      Button() {
                        Image($r('app.media.ic_back'))
                          .width(20)
                          .height(20)
                          .fillColor(this.themeState.getPlayPageForegroundColor())
                      }
                      .width(40)
                      .height(40)
                      .borderRadius(20)
                      .backgroundColor(this.themeState.getCardBackgroundColor())
                      .margin({ right: 8 })
                      .onClick(() => {
                        this.scrollController.scrollTo({ xOffset: 0, yOffset: 0, animation: true })
                      })
                    }
                    if (this.showScrollBottomButton) {
                      Button() {
                        Image($r('app.media.ic_next'))
                          .width(20)
                          .height(20)
                          .fillColor(this.themeState.getPlayPageForegroundColor())
                      }
                      .width(40)
                      .height(40)
                      .borderRadius(20)
                      .backgroundColor(this.themeState.getCardBackgroundColor())
                      .onClick(() => {
                        this.scrollController.scrollTo({ xOffset: 0, yOffset: this.playState.playList.length * 60, animation: true })
                      })
                    }
                  }
                  .position({ bottom: 16, right: 16 })
                  .zIndex(999)
                }
              }
              .width('100%')
              .height('100%')
              .backgroundColor(this.themeState.getCardBackgroundColor())
            }
            .position({ y: '80%' })
            .height(this.getPanelHeight())
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .opacity(this.panelOpacity)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }
        }
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .hideTitleBar(true)
  }
}