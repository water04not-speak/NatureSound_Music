// 搜索页面
import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import { SongItemType } from '../models/music'
import { playManager } from '../utils/AvPlayerManager'
import { GlobalMusic } from '../models/globalMusic'
import common from '@ohos.app.ability.common'

@Builder
export function SearchBuilder() {
  SearchPage()
}

@ComponentV2
export struct SearchPage {
  @Local searchText: string = ''
  @Local searchResults: SongItemType[] = []
  @Local isSearching: boolean = false
  @Local searchHistory: string[] = []
  @Local hotSearches: string[] = [
    '毛不易',
    'Unit 731',
    'YOUTH',
    '吹梦到西洲',
    '杜宣达',
    '李荣浩',
    '青丝'
  ]
  
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  playState: GlobalMusic = playManager.currentSong
  
  // 模拟歌曲库（实际应从服务器获取）
  private allSongs: SongItemType[] = [
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
  
  aboutToAppear() {
    // 加载搜索历史（实际应从本地存储加载）
    const abilityCtx = getContext(this) as common.UIAbilityContext
    void this.themeState.initFromContext(abilityCtx)
  }
  
  // 执行搜索
  private performSearch(keyword: string): void {
    if (!keyword.trim()) {
      return
    }
    
    this.isSearching = true
    this.searchText = keyword
    
    // 模拟搜索延迟
    setTimeout(() => {
      // 简单的关键词匹配（实际应调用搜索API）
      const results = this.allSongs.filter(song => 
        song.name.includes(keyword) || song.author.includes(keyword)
      )
      
      this.searchResults = results
      this.isSearching = false
      
      // 保存搜索历史
      if (!this.searchHistory.includes(keyword)) {
        this.searchHistory.unshift(keyword)
        if (this.searchHistory.length > 10) {
          this.searchHistory.pop()
        }
      }
    }, 500)
  }
  
  // 清除搜索历史
  private clearHistory(): void {
    this.searchHistory = []
  }
  
  build() {
    NavDestination() {
      Column() {
        // 搜索框
        Row({ space: 12 }) {
          Image($r('app.media.ic_search'))
            .width(20)
            .fillColor(this.themeState.getSecondaryTextColor())
          
          TextInput({ placeholder: '搜索歌曲、歌手', text: this.searchText })
            .layoutWeight(1)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .caretColor('#34C9C3')
            .onSubmit(() => {
              if (this.searchText && this.searchText.trim()) {
                this.performSearch(this.searchText.trim())
              }
            })
            .onChange((value: string) => {
              this.searchText = value
            })
          
          if (this.searchText) {
            Image($r('app.media.ic_close'))
              .width(18)
              .fillColor(this.themeState.getSecondaryTextColor())
              .onClick(() => {
                this.searchText = ''
                this.searchResults = []
              })
          }
        }
        .width('100%')
        .height(44)
        .backgroundColor(this.themeState.getSearchBarColor())
        .borderRadius(22)
        .padding({ left: 16, right: 16 })
        .margin({ left: 16, right: 16, top: 12, bottom: 12 })
        
        // 内容区域
        if (this.searchResults.length > 0) {
          // 显示搜索结果
          List() {
            ForEach(this.searchResults, (item: SongItemType) => {
              ListItem() {
                Row({ space: 12 }) {
                  Image(item.img)
                    .width(60)
                    .height(60)
                    .borderRadius(8)
                  
                  Column({ space: 6 }) {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeState.getPrimaryTextColor())
                      .width('100%')
                      .textAlign(TextAlign.Start)
                    
                    Text(item.author)
                      .fontSize(13)
                      .fontColor(this.themeState.getSecondaryTextColor())
                      .width('100%')
                      .textAlign(TextAlign.Start)
                  }
                  .layoutWeight(1)
                  
                  Image($r('app.media.ic_more'))
                    .width(24)
                    .fillColor(this.themeState.getIconColor())
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .onClick(() => {
                  this.pathStack.pushPathByName('Play', null, false)
                  playManager.singPlay(item)
                })
              }
            }, (item: SongItemType) => item.id)
          }
          .layoutWeight(1)
          .width('100%')
          .height('100%')
        } else if (this.isSearching) {
          // 搜索中
          Column() {
            LoadingProgress()
            Text('搜索中...')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 默认显示：搜索历史和热门搜索
          Scroll() {
            Column({ space: 20 }) {
              // 搜索历史
              if (this.searchHistory.length > 0) {
                Column({ space: 12 }) {
                  Row() {
                    Text('搜索历史')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeState.getPrimaryTextColor())
                      .layoutWeight(1)
                    
                    Text('清除')
                      .fontSize(13)
                      .fontColor(this.themeState.getSecondaryTextColor())
                      .onClick(() => {
                        this.clearHistory()
                      })
                  }
                  .width('100%')
                  
                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
                    ForEach(this.searchHistory, (keyword: string) => {
                      Text(keyword)
                        .fontSize(13)
                        .fontColor(this.themeState.getPrimaryTextColor())
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor(this.themeState.getCardBackgroundColor())
                        .borderRadius(16)
                        .margin({ right: 12, bottom: 12 })
                        .onClick(() => {
                          this.performSearch(keyword)
                        })
                    }, (keyword: string) => keyword)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding({ left: 16, right: 16 })
              }
              
              // 热门搜索
              Column({ space: 12 }) {
                Text('热门搜索')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeState.getPrimaryTextColor())
                  .width('100%')
                
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
                  ForEach(this.hotSearches, (keyword: string, index: number) => {
                    Row({ space: 6 }) {
                      if (index < 3) {
                        Text(`${index + 1}`)
                          .fontSize(12)
                          .fontColor('#FF6E9E')
                          .fontWeight(FontWeight.Bold)
                      }
                      Text(keyword)
                        .fontSize(13)
                        .fontColor(this.themeState.getPrimaryTextColor())
                    }
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.themeState.getCardBackgroundColor())
                    .borderRadius(16)
                    .margin({ right: 12, bottom: 12 })
                    .onClick(() => {
                      this.performSearch(keyword)
                    })
                  }, (keyword: string) => keyword)
                }
                .width('100%')
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .padding({ top: 8, bottom: 20 })
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .title('搜索')
    .hideTitleBar(false)
  }
}

