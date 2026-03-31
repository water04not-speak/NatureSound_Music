// 非遗之声 - 地域详情页，展示该地域的非遗歌曲列表

import { AppStorageV2 } from '@kit.ArkUI'
import { SongItemType } from '../models/music'
import { playManager } from '../utils/AvPlayerManager'
import { ThemeState } from '../models/theme'
import { getScreenHeightVp, getScreenWidthVp, resolveByScreenHeight, resolveByScreenWidth } from '../utils/ScreenUtils'

// 地域参数类
export class HeritageRegionParams {
  regionId: string = ''
  regionName: string = '非遗之声'
  regionCover: ResourceStr = $r('app.media.ic_cd')
  regionDescription: string = ''
}

@Builder
export function HeritageRegionDetailBuilder() {
  HeritageRegionDetail()
}

@ComponentV2
struct HeritageRegionDetail {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  regionParams: HeritageRegionParams = AppStorageV2.connect(HeritageRegionParams, 'heritageRegionParams',
    () => new HeritageRegionParams())!

  // 各地域非遗歌曲列表（来自《地域之声-音频图片》文档）
  private regionSongsMap: Record<string, SongItemType[]> = {
    'yangtze-delta': [
      { name: '欢乐歌', author: '民乐', url: 'http://music.163.com/song/media/outer/url?id=5259247.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.pVp5RhSikU2DDsTE0QxeSwHaE8?w=270&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'yd-001' },
      { name: '三六', author: '周炳生', url: 'http://music.163.com/song/media/outer/url?id=29802872.mp3', img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.VRtOLlArAVfpqwsN6PAU6QAAAA?w=158&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'yd-002' },
      { name: '莺莺拜月', author: '侯莉君', url: 'http://music.163.com/song/media/outer/url?id=247149.mp3', img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.vybPOLQES4LBfADLsPdH6QHaHa?w=149&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'yd-003' },
      { name: '秦淮景', author: '吴亮莹', url: 'http://music.163.com/song/media/outer/url?id=1406232229.mp3', img: 'https://puui.qpic.cn/vpic_cover/c3512n6ggxf/c3512n6ggxf_1683183566_hz.jpg/1280', id: 'yd-004' },
      { name: '白蛇.赏中秋', author: '蒋月泉', url: 'http://music.163.com/song/media/outer/url?id=105734.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.M4zTP61wv_h1aZ5eU8W-mgAAAA?w=213&h=186&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'yd-005' },
      { name: '牡丹亭-游园惊梦', author: '梅兰芳,白云生,韩世昌', url: 'http://music.163.com/song/media/outer/url?id=1923225787.mp3', img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.nR6SX5GcEy9954eaW9g9BQHaKU?w=124&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'yd-006' },
      { name: '长生殿.絮阁', author: '群星', url: 'http://music.163.com/song/media/outer/url?id=5266378.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.mxEjCKVjDq-2F5ZDIs0EHQAAAA?w=208&h=222&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'yd-007' }
    ],
    'guangdong-hk-macao': [
      { name: '分飞燕', author: '群星', url: 'http://music.163.com/song/media/outer/url?id=5282935.mp3', img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.GzenW0inyAA1jmpMM9HTowAAAA?w=182&h=182&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ghm-001' },
      { name: '帝女花', author: '郑少秋,佩佩', url: 'http://music.163.com/song/media/outer/url?id=195616.mp3', img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.ax0QLz18kKy7BM6n7OxY3gHaKY?w=133&h=187&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ghm-002' },
      { name: '彩云追月', author: '嫚孋', url: 'http://music.163.com/song/media/outer/url?id=279344.mp3', img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.UCrCEt8DH4kv8WgZQ-Uj3wAAAA?w=206&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2', id: 'ghm-003' },
      { name: '氹氹转', author: '小紫荆儿童合唱团', url: 'http://music.163.com/song/media/outer/url?id=388688.mp3', img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.IfK8L7m1EaXUU69162ffsAAAAA?w=161&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ghm-004' },
      { name: '落雨大', author: '广州少儿广播合唱团', url: 'http://music.163.com/song/media/outer/url?id=1983785753.mp3', img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.T2tPE46c8NE0yFmUJHk9AgHaHa?w=155&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ghm-005' },
      { name: '醒狮鼓乐', author: '群星', url: 'http://music.163.com/song/media/outer/url?id=25730867.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.rnDVRLME-Uzxl43yfreB3gHaEJ?w=294&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ghm-006' }
    ],
    'chengdu-chongqing': [
      { name: '别洞观景', author: '筱舫', url: 'http://music.163.com/song/media/outer/url?id=1899930770.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.fhYo85gggaivvIBL75EyIQHaE8?w=301&h=201&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ccq-001' },
      { name: '连升店', author: '周金福,陈宝亮', url: 'http://music.163.com/song/media/outer/url?id=1923444673.mp3', img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.dMZbQPzODnK_o0KMXz7G1gHaFI?w=283&h=196&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ccq-002' },
      { name: '川剧-贵妃醉酒', author: '阳友鹤', url: 'http://music.163.com/song/media/outer/url?id=5266402.mp3', img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.cFNK2TUUWX9dmsCg-1qQugHaE8?w=300&h=200&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ccq-003' },
      { name: '变脸川剧鼓点', author: '雾都游子', url: 'http://music.163.com/song/media/outer/url?id=2056203042.mp3', img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.ddVmao1EJWB1vsCOWMGO8gHaFT?w=233&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ccq-004' }
    ],
    'yangtze-mid': [
      { name: '拜月记', author: '李忆兰', url: 'http://music.163.com/song/media/outer/url?id=1899033788.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.xm7HX1Wmt95eZHxwFpdJLAHaFN?w=273&h=193&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ym-001' },
      { name: '刘海砍樵(湖南花鼓戏)', author: '李谷一', url: 'http://music.163.com/song/media/outer/url?id=1914675120.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.TrXzBOYmRZ-i8hcyA9gOlwHaFj?w=246&h=184&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ym-002' },
      { name: '女驸马', author: '韩再芬', url: 'http://music.163.com/song/media/outer/url?id=1501412078.mp3', img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.S4b74px7Ght-QIlA_6AT7AAAAA?w=179&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ym-003' },
      { name: '天仙配', author: '韩再芬,刘国平', url: 'http://music.163.com/song/media/outer/url?id=1501408933.mp3', img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.iSiO7zc4Eg2eKq5BVsA7OAHaE-?w=246&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ym-004' },
      { name: '打猪草', author: '吴琼,张辉', url: 'http://music.163.com/song/media/outer/url?id=2165171173.mp3', img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.jRG1xmb6fpXEaiyOQBGQfgHaEK?w=333&h=187&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'ym-005' }
    ],
    'ancient-style': [
      { img: 'https://ts2.tc.mm.bing.net/th/id/OIP-C.S0lemtICbjqpaSpjD1X5fgHaHa?w=200&h=200&c=12&rs=1&p=0&o=6&dpr=1.5&pid=23.1', name: '吹梦到西洲', author: '恋恋故人难,黄诗扶,王敬轩（妖扬）', url: 'http://music.163.com/song/media/outer/url?id=1376873330.mp3', id: '0007' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.pwQpy7yybxiaMVdf5JN1SwHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '青丝', author: '等什么君(邓寓君)', url: 'http://music.163.com/song/media/outer/url?id=1412672813.mp3', id: '0029' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l84WVS0LEO3AkgPhgLd5BgHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '明月天涯 (翻自 五音JW)', author: '等什么君(邓寓君)', url: 'http://music.163.com/song/media/outer/url?id=1344878089.mp3', id: '0030' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.803Wns_LS5LsyF9jPNCBJQHaHa?w=138&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '陌路逢君', author: '等什么君(邓寓君)', url: 'http://music.163.com/song/media/outer/url?id=1415078083.mp3', id: '0031' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.r0bLQc8njyOVgXPYuNjSzwHaHa?w=146&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '囍（女生版）', author: '等什么君(邓寓君)', url: 'http://music.163.com/song/media/outer/url?id=1496822949.mp3', id: '0032' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.oGXTK2UGnaPubp-8sK2z4gHaNK?w=114&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '故梦（Cover 橙翼）', author: '双笙（陈元汐）', url: 'http://music.163.com/song/media/outer/url?id=409654891.mp3', id: '0033' },
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.SpdFHZJH6jCmCFpZdVONFgHaHa?w=161&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '我的一个道姑朋友', author: '双笙（陈元汐）', url: 'http://music.163.com/song/media/outer/url?id=1367452194.mp3', id: '0034' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.8Ug45VtRuUQEKvQ_dFidwAHaEo?w=256&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '世末歌者（Cover 乐正绫）', author: '双笙（陈元汐）,封茗囧菌', url: 'http://music.163.com/song/media/outer/url?id=429460399.mp3', id: '0035' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.Fa9_7omqnMvDG4ISsVHpgAAAAA?w=212&h=176&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '琴师', author: '徐泽（要不要买菜）', url: 'http://music.163.com/song/media/outer/url?id=1406119516.mp3', id: '0046' }
    ],
    'modern-style': [
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.du5HkZPRv8NeBiI8lyTe2gHaCu?w=343&h=128&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '消愁', author: '毛不易', url: 'http://music.163.com/song/media/outer/url?id=569200213.mp3', id: '0000' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C._LJNEo0ekqtNZL-BmOn3VAHaHa?w=199&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: 'Unit 731', author: 'Tim Moyo', url: 'http://music.163.com/song/media/outer/url?id=2731054516.mp3', id: '0001' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.6O62_eW-0x3-2s0cdubTigHaEN?w=253&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: 'YOUTH', author: 'Troye Sivan', url: 'http://music.163.com/song/media/outer/url?id=2731576429.mp3', id: '0002' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.S6-SPRMftLydAsbrGxMnKgHaHa?w=206&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: 'LOST BOY', author: 'Troye Sivan', url: 'http://music.163.com/song/media/outer/url?id=37988002.mp3', id: '0003' },
      { img: 'https://ts4.tc.mm.bing.net/th/id/OIP-C.l89zozjdw7Av41tZhMBLHQHaHZ?w=312&h=200&c=12&rs=1&o=6&dpr=1.5&pid=23.1', name: 'テロメアの産声', author: '4円', url: 'http://music.163.com/song/media/outer/url?id=26447699.mp3', id: '0004' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.JsCp2kFMJQNUiJr1z6PztQAAAA?w=151&h=169&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: 'YELLOW', author: '4円', url: 'http://music.163.com/song/media/outer/url?id=1877061646.mp3', id: '0005' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.hsNjPtdOhkVKvQVC4ldOoQAAAA?w=179&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: 'My Heart Will Go On', author: '满舒克,MuSik I,廖伟珊', url: 'http://music.163.com/song/media/outer/url?id=26524701.mp3', id: '0006' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.b9__SJlShsleGBZklex6ewHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: '致你', author: 'yihuik苡慧', url: 'http://music.163.com/song/media/outer/url?id=1867217766.mp3', id: '0008' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.0reb7d1pRce8SAm-AiHyjAHaHa?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: '孤独患者', author: '杜宣达', url: 'http://music.163.com/song/media/outer/url?id=2642002866.mp3', id: '0009' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.5vMonFOGX7ZQZxN4kAJq6wAAAA?w=190&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: '精卫', author: '一颗狼星', url: 'http://music.163.com/song/media/outer/url?id=2019279516.mp3', id: '0011' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.VuIUZtzmpXgromK5aXymdAHaHa?w=163&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '两 难', author: '加木', url: 'http://music.163.com/song/media/outer/url?id=2163210456.mp3', id: '0012' },
      { img: 'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/c8/c4/fa/c8c4fa47-55d8-b5ba-96e5-4b7de76b18e3/cover.jpg/1200x630wp-60.jpg', name: '戒断反应', author: '赵政豪', url: 'http://music.163.com/song/media/outer/url?id=2600442564.mp3', id: '0013' },
      { img: 'https://img3.kuwo.cn/star/albumcover/500/s4s61/83/1393076434.jpg', name: '给未来的自己', author: '余翊', url: 'http://music.163.com/song/media/outer/url?id=3327521028.mp3', id: '0014' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6cVHkHcjY27leNEticrH4QHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '迷雾', author: '吴子健REmi', url: 'http://music.163.com/song/media/outer/url?id=3329325495.mp3', id: '0015' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.DbFschoMC4D56w-hISUNKwAAAA?w=188&h=188&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '霜月遥 - イノチの灯し方 (生命的点燃方式)', author: '霜月瑶', url: 'http://music.163.com/song/media/outer/url?id=473403622.mp3', id: '0016' },
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.XCD3rC-U3JB5VemZf1NC1gHaEK?w=285&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '春日影', author: 'CRYCHIC', url: 'http://music.163.com/song/media/outer/url?id=2154464431.mp3', id: '0017' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.bkXzlU64xLuz4OR9A4mJdwAAAA?w=160&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: '像雾', author: '徐秉龙', url: 'http://music.163.com/song/media/outer/url?id=1941323235.mp3', id: '0018' },
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.GVsvj4J7mH4y5W-nJkY9XwAAAA?w=207&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: 'shall we talk.', author: '8bite', url: 'http://music.163.com/song/media/outer/url?id=1986510161.mp3', id: '0020' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.61af9pSkqIrYBNohjSPBrAHaHa?w=170&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '越来越不懂（Cover 蔡健雅）', author: '青尢', url: 'http://music.163.com/song/media/outer/url?id=498311468.mp3', id: '0021' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.vV33icWm5aacmPSnZHg4tgHaGO?w=184&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '勾指起誓', author: '青尢', url: 'http://music.163.com/song/media/outer/url?id=1362503051.mp3', id: '0022' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.Wd5ltXER23yV7zpHskJnrwHaHa?w=178&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '夏天的风（Cover 温岚）', author: '青尢', url: 'http://music.163.com/song/media/outer/url?id=519479311.mp3', id: '0023' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.1D9C1vapkptbrgC4gJfpzAHaEu?w=269&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '会不会（吉他版）', author: '刘大壮', url: 'http://music.163.com/song/media/outer/url?id=1481164987.mp3', id: '0024' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.BjlCBcr1ivyWGIw-ltPSIQHaHa?w=176&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '我很好（吉他版）', author: '刘大壮', url: 'http://music.163.com/song/media/outer/url?id=1491221473.mp3', id: '0025' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.-aRtG0KjxMEUlPQrqDnIuwHaHa?w=181&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '三号线（吉他版）', author: '刘大壮', url: 'http://music.163.com/song/media/outer/url?id=1497799734.mp3', id: '0026' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.rU8WoMhtKnlk-VqRPbVYwgHaHa?w=173&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '同花顺', author: 'en（王翊恩）', url: 'http://music.163.com/song/media/outer/url?id=2709706245.mp3', id: '0027' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.7D2qL-1OoZ1foMTd05W3kwHaHa?w=177&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '想自由', author: 'en（王翊恩）', url: 'http://music.163.com/song/media/outer/url?id=2713633715.mp3', id: '0028' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.cvib5ZJDR6YVN_AVEvuqlQHaI_?w=140&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '像我这样的人', author: '毛不易', url: 'http://music.163.com/song/media/outer/url?id=569213220.mp3', id: '0036' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l89zozjdw7Av41tZhMBLHQHaHZ?w=162&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '文学少年の憂鬱', author: '4円', url: 'http://music.163.com/song/media/outer/url?id=26447696.mp3', id: '0037' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.tdBGKfY0RY1jG9nGAGG4wwHaE6?w=253&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '北京东路的日子', author: '汪源', url: 'http://music.163.com/song/media/outer/url?id=458245372.mp3', id: '0038' },
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.UnCdU7b4l1oRsWkoTYHDvAAAAA?w=156&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '仙', author: '江皓南', url: 'http://music.163.com/song/media/outer/url?id=2705662118.mp3', id: '0039' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.oBBTKCjV31L4b55GaaVfGgHaHa?w=185&h=192&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '隐喻', author: '廖泽蓝,蘑菇鼠牙', url: 'http://music.163.com/song/media/outer/url?id=3342356985.mp3', id: '0040' },
      { img: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.lMO1xR8TqlSl1Bu50Ll8uQAAAA?w=142&h=188&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '假说', author: '张齐山', url: 'http://music.163.com/song/media/outer/url?id=2738482477.mp3', id: '0041' },
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.rtUjhJYVuztUUWDjvZD7LgHaHa?w=149&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: 'I Like Me Better', author: 'Lauv', url: 'http://music.163.com/song/media/outer/url?id=479223413.mp3', id: '0042' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.y_JPkbQMnC9apViwjVCcLgHaHa?w=184&h=184&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '形容', author: '沈以诚', url: 'http://music.163.com/song/media/outer/url?id=1336856864.mp3', id: '0043' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.X-8rIiiyDZkw8PXJaLdeigAAAA?w=224&h=147&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '告白', author: '沈以诚', url: 'http://music.163.com/song/media/outer/url?id=1336856449.mp3', id: '0044' },
      { img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.PRwQ-ELVfPSBH6QfA_JL3wHaE7?w=280&h=187&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '日落大桥', author: '不是花火呀', url: 'http://music.163.com/song/media/outer/url?id=1842743863.mp3', id: '0045' },
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.kUVSnw26NXrhSyFD0b-sWQHaGv?w=171&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: 'There\'s Nothing Holdin\'', author: 'Me Back - Shawn Mendes', url: 'http://music.163.com/song/media/outer/url?id=2656135242.mp3', id: '0047' }
    ],
    'wuxia-style': [
      { img: 'https://ts1.tc.mm.bing.net/th/id/OIP-C.KTyTNlQIovW5FKx1e-N_vgHaHa?w=194&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.5&pid=3.1&rm=2', name: '出山', author: '花粥,王胜娚', url: 'http://music.163.com/song/media/outer/url?id=1313354324.mp3', id: '0019' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l84WVS0LEO3AkgPhgLd5BgHaHa?w=203&h=203&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '明月天涯 (翻自 五音JW)', author: '等什么君(邓寓君)', url: 'http://music.163.com/song/media/outer/url?id=1344878089.mp3', id: '0030' }
    ],
    'folk-style': [
      { img: 'https://tse3-mm.cn.bing.net/th/id/OIP-C.du5HkZPRv8NeBiI8lyTe2gHaCu?w=343&h=128&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '消愁', author: '毛不易', url: 'http://music.163.com/song/media/outer/url?id=569200213.mp3', id: '0000' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.cvib5ZJDR6YVN_AVEvuqlQHaI_?w=140&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '像我这样的人', author: '毛不易', url: 'http://music.163.com/song/media/outer/url?id=569213220.mp3', id: '0036' },
      { img: 'https://tse4-mm.cn.bing.net/th/id/OIP-C.tdBGKfY0RY1jG9nGAGG4wwHaE6?w=253&h=180&c=7&r=0&o=7&dpr=1.5&pid=1.7&rm=3', name: '北京东路的日子', author: '汪源', url: 'http://music.163.com/song/media/outer/url?id=458245372.mp3', id: '0038' }
    ],
    'default': [
      { name: '欢乐歌', author: '民乐', url: 'http://music.163.com/song/media/outer/url?id=5259247.mp3', img: 'https://tse2-mm.cn.bing.net/th/id/OIP-C.pVp5RhSikU2DDsTE0QxeSwHaE8?w=270&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', id: 'def-001' }
    ]
  }

  get currentSongs(): SongItemType[] {
    return this.regionSongsMap[this.regionParams.regionId] || this.regionSongsMap['default']
  }

  // 响应式布局配置
  private getHeaderHeight(): number {
    return resolveByScreenHeight(getScreenHeightVp(), 280, 320, 320)
  }

  private getCoverSize(): number {
    return resolveByScreenWidth(getScreenWidthVp(), 120, 140, 140)
  }

  build() {
    NavDestination() {
      Column() {
        // 头部背景和信息
        Stack() {
          Image(this.regionParams.regionCover)
            .width('100%')
            .height(this.getHeaderHeight())
            .objectFit(ImageFit.Cover)
            .blur(50)

          // 渐变遮罩，确保文字清晰可见
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0.3)', 0], ['rgba(0,0,0,0.7)', 1]]
            })

          Column() {
            Image(this.regionParams.regionCover)
              .width(this.getCoverSize())
              .height(this.getCoverSize())
              .borderRadius(12)
              .border({ width: 3, color: this.themeState.getCardBackgroundColor() })
              .margin({ top: 40 })

            Text(this.regionParams.regionName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 16 })

            Text(this.regionParams.regionDescription)
              .fontSize(14)
              .fontColor(Color.White)
              .opacity(0.9)
              .margin({ top: 8, bottom: 20 })
              .padding({ left: 40, right: 40 })
              .textAlign(TextAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(this.getHeaderHeight())

        // 歌曲列表区域
        Scroll() {
          Column() {
            Row() {
              Text('非遗曲目')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeState.getPrimaryTextColor())
              Text(`${this.currentSongs.length}首`)
                .fontSize(14)
                .fontColor(this.themeState.getSecondaryTextColor())
                .margin({ left: 12 })
                .alignSelf(ItemAlign.End)
                .margin({ bottom: 2 })
            }
            .width('100%')
            .padding({ top: 10, left: 16, right: 16, bottom: 12 })
            .justifyContent(FlexAlign.Start)

            List() {
              ForEach(this.currentSongs, (song: SongItemType, index: number) => {
                ListItem() {
                  Row() {
                    // 排名
                    Text((index + 1).toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(index < 3 ? '#FF6B6B' : this.themeState.getSecondaryTextColor())
                      .width(32)
                      .textAlign(TextAlign.Center)
                      .margin({ right: 12 })

                    // 歌曲信息
                    Row() {
                      Image(song.img)
                        .width(80)
                        .height(80)
                        .borderRadius(8)
                        .margin({ right: 12 })

                      Column() {
                        Text(song.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.themeState.getPrimaryTextColor())
                          .width('100%')
                          .margin({ bottom: 8 })
                        Text(song.author)
                          .fontSize(14)
                          .fontColor(this.themeState.getSecondaryTextColor())
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)

                      // 播放按钮
                      Image($r('app.media.ic_play'))
                        .width(32)
                        .height(32)
                        .fillColor(this.themeState.getPrimaryTextColor())
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .height(100)
                  .padding({ left: 16, right: 16 })
                  .backgroundColor(this.themeState.getBackgroundColor())
                  .onClick(() => {
                    this.pathStack.pushPathByName('Play', null, false)
                    playManager.singPlayFromList(song, this.currentSongs)
                  })
                }
              }, (song: SongItemType) => song.id)
            }
            .width('100%')
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .padding({ bottom: 20 })
          }
          .width('100%')
          .backgroundColor(this.themeState.getBackgroundColor())
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title(this.regionParams.regionName)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
