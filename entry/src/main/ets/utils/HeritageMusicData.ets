import { SongItemType } from '../models/music'
import { MusicSongSeed } from '../models/musicDb'

interface HeritageSeed extends MusicSongSeed {
  regionId: string
}

function normalizeStreamUrl(url: string): string {
  if (url.startsWith('http://music.163.com/')) {
    return 'https://' + url.substring('http://'.length)
  }
  return url
}

const heritageSeedsByRegion: Record<string, HeritageSeed[]> = {
  'yangtze-delta': [
    { id: 'h000', regionId: 'yangtze-delta', title: '欢乐歌', singer: '民乐', url: 'https://music.163.com/song/media/outer/url?id=5259247.mp3', cover: 'https://picsum.photos/seed/h000/320/320' },
    { id: 'h001', regionId: 'yangtze-delta', title: '三六', singer: '周炳生', url: 'https://music.163.com/song/media/outer/url?id=29802872.mp3', cover: 'https://picsum.photos/seed/h001/320/320' },
    { id: 'h002', regionId: 'yangtze-delta', title: '莺莺拜月', singer: '侯莉君', url: 'https://music.163.com/song/media/outer/url?id=247149.mp3', cover: 'https://picsum.photos/seed/h002/320/320' },
    { id: 'h003', regionId: 'yangtze-delta', title: '秦淮景', singer: '吴亮莹', url: 'https://music.163.com/song/media/outer/url?id=1406232229.mp3', cover: 'https://picsum.photos/seed/h003/320/320' },
    { id: 'h004', regionId: 'yangtze-delta', title: '白蛇·赏中秋', singer: '蒋月泉', url: 'https://music.163.com/song/media/outer/url?id=105734.mp3', cover: 'https://picsum.photos/seed/h004/320/320' },
    { id: 'h005', regionId: 'yangtze-delta', title: '牡丹亭·游园惊梦', singer: '梅兰芳,白云生,韩世昌', url: 'https://music.163.com/song/media/outer/url?id=1923225787.mp3', cover: 'https://picsum.photos/seed/h005/320/320' },
    { id: 'h006', regionId: 'yangtze-delta', title: '长生殿·絮阁', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=5266378.mp3', cover: 'https://picsum.photos/seed/h006/320/320' }
  ],
  'guangdong-hk-macao': [
    { id: 'h007', regionId: 'guangdong-hk-macao', title: '分飞燕', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=5282935.mp3', cover: 'https://picsum.photos/seed/h007/320/320' },
    { id: 'h008', regionId: 'guangdong-hk-macao', title: '帝女花', singer: '郑少秋,佩佩', url: 'https://music.163.com/song/media/outer/url?id=195616.mp3', cover: 'https://picsum.photos/seed/h008/320/320' },
    { id: 'h009', regionId: 'guangdong-hk-macao', title: '彩云追月', singer: '嫚孋', url: 'https://music.163.com/song/media/outer/url?id=279344.mp3', cover: 'https://picsum.photos/seed/h009/320/320' },
    { id: 'h010', regionId: 'guangdong-hk-macao', title: '氹氹转', singer: '小紫荆儿童合唱团', url: 'https://music.163.com/song/media/outer/url?id=388688.mp3', cover: 'https://picsum.photos/seed/h010/320/320' },
    { id: 'h011', regionId: 'guangdong-hk-macao', title: '落雨大', singer: '广州少儿广播合唱团', url: 'https://music.163.com/song/media/outer/url?id=1983785753.mp3', cover: 'https://picsum.photos/seed/h011/320/320' },
    { id: 'h012', regionId: 'guangdong-hk-macao', title: '醒狮鼓乐', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=25730867.mp3', cover: 'https://picsum.photos/seed/h012/320/320' }
  ],
  'chengdu-chongqing': [
    { id: 'h013', regionId: 'chengdu-chongqing', title: '别洞观景', singer: '筱舫', url: 'https://music.163.com/song/media/outer/url?id=1899930770.mp3', cover: 'https://picsum.photos/seed/h013/320/320' },
    { id: 'h014', regionId: 'chengdu-chongqing', title: '连升店', singer: '周金福,陈宝亮', url: 'https://music.163.com/song/media/outer/url?id=1923444673.mp3', cover: 'https://picsum.photos/seed/h014/320/320' },
    { id: 'h015', regionId: 'chengdu-chongqing', title: '川剧·贵妃醉酒', singer: '群星', url: 'https://music.163.com/song/media/outer/url?id=5266402.mp3', cover: 'https://picsum.photos/seed/h015/320/320' },
    { id: 'h016', regionId: 'chengdu-chongqing', title: '变脸川剧鼓点', singer: '雾都游子', url: 'https://music.163.com/song/media/outer/url?id=2056203042.mp3', cover: 'https://picsum.photos/seed/h016/320/320' }
  ],
  'yangtze-mid': [
    { id: 'h017', regionId: 'yangtze-mid', title: '拜月记', singer: '李忆兰', url: 'https://music.163.com/song/media/outer/url?id=1899033788.mp3', cover: 'https://picsum.photos/seed/h017/320/320' },
    { id: 'h018', regionId: 'yangtze-mid', title: '刘海砍樵(湖南花鼓戏)', singer: '李谷一', url: 'https://music.163.com/song/media/outer/url?id=1914675120.mp3', cover: 'https://picsum.photos/seed/h018/320/320' },
    { id: 'h019', regionId: 'yangtze-mid', title: '女驸马', singer: '韩再芬', url: 'https://music.163.com/song/media/outer/url?id=1501412078.mp3', cover: 'https://picsum.photos/seed/h019/320/320' },
    { id: 'h020', regionId: 'yangtze-mid', title: '天仙配', singer: '韩再芬,刘国平', url: 'https://music.163.com/song/media/outer/url?id=1501408933.mp3', cover: 'https://picsum.photos/seed/h020/320/320' },
    { id: 'h021', regionId: 'yangtze-mid', title: '打猪草', singer: '吴琼,张辉', url: 'https://music.163.com/song/media/outer/url?id=2165171173.mp3', cover: 'https://picsum.photos/seed/h021/320/320' }
  ]
}

const flatHeritageSeeds: HeritageSeed[] = []
Object.keys(heritageSeedsByRegion).forEach((regionId: string) => {
  const list = heritageSeedsByRegion[regionId]
  list.forEach((item: HeritageSeed) => flatHeritageSeeds.push(item))
})

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
