import { AppStorageV2 } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { ThemeState } from '../models/theme'
import { SongItemType } from '../models/music'
import { getScreenWidthVp, resolveByScreenWidth } from '../utils/ScreenUtils'
import { getDefaultSongItems } from '../utils/MusicSeedData'
import { getHeritageSongsByRegionId, loadLocalHeritageSongsByRegion } from '../utils/HeritageMusicData'
import { HeritageRegionParams } from './HeritageRegionDetail'

interface HeritageRegionItem {
  id: string
  name: string
  cover: ResourceStr
  description: string
}

@Builder
export function MusicFeastBuilder() {
  MusicFeast()
}

@ComponentV2
export struct MusicFeast {
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  private readonly songPool: SongItemType[] = getDefaultSongItems()
  @Local private localHeritageSongsByRegion: Record<string, SongItemType[]> = {}

  private readonly regionFallbackIds: Record<string, string[]> = {
    'yangtze-delta': ['demo-heritage-001', 'demo-heritage-005'],
    'guangdong-hk-macao': ['demo-heritage-002', 'demo-heritage-006'],
    'chengdu-chongqing': ['demo-heritage-003', 'demo-heritage-007'],
    'yangtze-mid': ['demo-heritage-004', 'demo-heritage-008'],
    'ancient-style': ['demo-heritage-009', 'demo-heritage-010'],
    'modern-style': ['demo-heritage-011', 'demo-heritage-012'],
    'wuxia-style': ['demo-heritage-013', 'demo-heritage-014'],
    'folk-style': ['demo-heritage-015', 'demo-heritage-016']
  }

  @Local private regionList: HeritageRegionItem[] = [
    {
      id: 'yangtze-delta',
      name: '长三角地区',
      cover: $r('app.media.csj01'),
      description: '江南丝竹、评弹小调、昆曲选段'
    },
    {
      id: 'guangdong-hk-macao',
      name: '粤港澳地区',
      cover: $r('app.media.yga01'),
      description: '广府粤曲、粤语童谣、醒狮鼓点'
    },
    {
      id: 'chengdu-chongqing',
      name: '成渝地区',
      cover: $r('app.media.cy01'),
      description: '川剧念白、川剧鼓点音效'
    },
    {
      id: 'yangtze-mid',
      name: '长江中游地区',
      cover: $r('app.media.cjzy01'),
      description: '楚调湘音、黄梅戏选段'
    },
    {
      id: 'ancient-style',
      name: '古风音乐',
      cover: $r('app.media.gf01'),
      description: '箫声、山水意象与传统器乐氛围'
    },
    {
      id: 'modern-style',
      name: '现代音乐',
      cover: $r('app.media.xd01'),
      description: '城市声景、电子律动与自然采样'
    },
    {
      id: 'wuxia-style',
      name: '武侠音乐',
      cover: $r('app.media.wx01'),
      description: '竹林、江湖与器乐叙事片段'
    },
    {
      id: 'folk-style',
      name: '民谣音乐',
      cover: $r('app.media.my01'),
      description: '田野采风、生活节奏与木吉他片段'
    }
  ]

  private ensurePlayableSong(song: SongItemType): SongItemType {
    return {
      img: song.img,
      name: song.name,
      author: song.author,
      url: song.url,
      id: song.id,
      title: song.title,
      singer: song.singer,
      cover: song.cover,
      lyric: song.lyric,
      isFavorite: song.isFavorite,
      createTime: song.createTime,
      lyrics: song.lyrics,
      lyricLines: song.lyricLines,
      lyricOffsetMs: song.lyricOffsetMs
    }
  }

  private resolveRegionSongs(region: HeritageRegionItem): SongItemType[] {
    const unique: Record<string, SongItemType> = {}

    const localSongs = this.localHeritageSongsByRegion[region.id] ?? []
    if (localSongs.length > 0) {
      for (const song of localSongs) {
        unique[song.id] = this.ensurePlayableSong(song)
      }
      return Object.values(unique)
    }

    const heritageSongs = getHeritageSongsByRegionId(region.id)
    for (const song of heritageSongs) {
      unique[song.id] = this.ensurePlayableSong(song)
    }

    const fallbackIds = this.regionFallbackIds[region.id] ?? []
    for (const id of fallbackIds) {
      if (unique[id]) {
        continue
      }
      const found = this.songPool.find((song: SongItemType) => song.id === id)
      if (found) {
        unique[id] = this.ensurePlayableSong(found)
      }
    }

    return Object.values(unique)
  }

  private handleRegionClick(region: HeritageRegionItem): void {
    const params = AppStorageV2.connect(HeritageRegionParams, 'heritageRegionParams', () => new HeritageRegionParams())!
    params.regionId = region.id
    params.regionName = region.name
    params.regionCover = region.cover
    params.regionDescription = region.description
    params.songs = this.resolveRegionSongs(region)
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

  private getColumnsCount(): string {
    return resolveByScreenWidth(getScreenWidthVp(), '1fr 1fr', '1fr 1fr 1fr', '1fr 1fr 1fr 1fr')
  }

  build() {
    Column() {
      Row() {
        Text('声宴')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.getPrimaryTextColor())
          .fontStyle(FontStyle.Italic)
          .opacity(0.72)
        Text('  Music Feast ~')
          .fontSize(14)
          .fontStyle(FontStyle.Italic)
          .fontFamily('serif')
          .opacity(0.82)
          .letterSpacing(1.1)
          .fontColor(this.themeState.getSecondaryTextColor())
          .margin({ left: 12 })
          .alignSelf(ItemAlign.End)
          .margin({ bottom: 4, left: 2 })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 4 })
      .justifyContent(FlexAlign.Start)

      Text('聆听山河古韵，传承千年声脉。一方水土一方歌，让多元音乐在数字时代生生不息。')
        .fontSize(14)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width('100%')
        .padding({ left: 8, right: 8, bottom: 8 })
        .textAlign(TextAlign.Start)

      Grid() {
        ForEach(this.regionList, (item: HeritageRegionItem) => {
          GridItem() {
            this.renderRegionCard(item)
          }
        }, (item: HeritageRegionItem) => item.id)
      }
      .columnsTemplate(this.getColumnsCount())
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 8, right: 8, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.getBackgroundColor())
    .expandSafeArea()
    .onAppear(() => {
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void this.themeState.initFromContext(abilityCtx)
      void loadLocalHeritageSongsByRegion(abilityCtx).then((songsByRegion: Record<string, SongItemType[]>) => {
        this.localHeritageSongsByRegion = songsByRegion
      }).catch((error: Error) => {
        console.warn('[MusicFeast] Failed to load local heritage private config:', error.message)
        this.localHeritageSongsByRegion = {}
      })
    })
  }
}
